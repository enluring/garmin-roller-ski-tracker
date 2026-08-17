import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Timer;

// Main data screen: elapsed session time, distance, pace and heart rate.
// Refreshed once a second by a Timer while the view is shown, reading the
// live values from Activity.getActivityInfo() (fed by the ActivityRecording
// session RollerSkiTrackerApp starts once a ski type is picked).
//
// The first time this view is shown, it puts up a ski-type picker
// (SkiTypePickerDelegate) on top of itself; RollerSkiTrackerApp.beginSession
// only starts the recording session once a choice has been made.
class RollerSkiTrackerView extends WatchUi.View {

    private var _updateTimer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        _updateTimer = new Timer.Timer();
        _updateTimer.start(method(:onUpdateTimer), 1000, true);

        if (!getApp().isSessionStarted()) {
            showSkiTypePicker();
        }
    }

    private function showSkiTypePicker() as Void {
        var menu = new WatchUi.Menu2({:title => "Ski type"});
        menu.addItem(new WatchUi.MenuItem("Classic", null, :classic, null));
        menu.addItem(new WatchUi.MenuItem("Skate", null, :skate, null));
        menu.addItem(new WatchUi.MenuItem("Double poling", null, :doublePoling, null));
        WatchUi.pushView(menu, new SkiTypePickerDelegate(), WatchUi.SLIDE_UP);
    }

    function onUpdateTimer() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        var info = Activity.getActivityInfo();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.06, Graphics.FONT_XTINY, getApp().getSkiTypeLabel(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        drawStat(dc, width / 2, height * 0.24, "TIME", formatElapsedTime(info));
        drawStat(dc, width / 2, height * 0.46, "DISTANCE", formatDistance(info));
        drawStat(dc, width / 2, height * 0.68, "PACE", formatPace(info));
        drawStat(dc, width / 2, height * 0.90, "HEART RATE", formatHeartRate(info));
    }

    function onHide() as Void {
        if (_updateTimer != null) {
            _updateTimer.stop();
            _updateTimer = null;
        }
    }

    private function drawStat(dc as Dc, x as Numeric, y as Numeric, label as String, value as String) as Void {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - 14, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + 2, Graphics.FONT_MEDIUM, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Active recording time (excludes paused time), formatted h:mm:ss once
    // an hour has elapsed, mm:ss before that.
    private function formatElapsedTime(info as Activity.Info?) as String {
        if (info == null || info.timerTime == null) {
            return "--:--";
        }

        var totalSeconds = info.timerTime / 1000;
        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var seconds = totalSeconds % 60;

        if (hours > 0) {
            return hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        }
        return minutes.format("%02d") + ":" + seconds.format("%02d");
    }

    private function formatDistance(info as Activity.Info?) as String {
        if (info == null || info.elapsedDistance == null) {
            return "--.-- km";
        }
        return (info.elapsedDistance / 1000.0).format("%.2f") + " km";
    }

    // Pace in min/km, derived from current speed (m/s). Below walking pace
    // there's no meaningful pace to show.
    private function formatPace(info as Activity.Info?) as String {
        if (info == null || info.currentSpeed == null || info.currentSpeed < 0.3) {
            return "--:-- /km";
        }

        var secondsPerKm = 1000.0 / info.currentSpeed;
        var minutes = (secondsPerKm / 60).toNumber();
        var seconds = (secondsPerKm - minutes * 60).toNumber();
        return minutes.format("%d") + ":" + seconds.format("%02d") + " /km";
    }

    private function formatHeartRate(info as Activity.Info?) as String {
        if (info == null || info.currentHeartRate == null) {
            return "-- bpm";
        }
        return info.currentHeartRate.format("%d") + " bpm";
    }

}
