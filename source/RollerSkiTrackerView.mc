import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

// Placeholder main screen. Owns the activity recording session and shows
// elapsed time/distance/speed while recording. Will grow into proper
// technique-metric data screens later.
class RollerSkiTrackerView extends WatchUi.View {

    private var mSession as ActivityRecording.Session?;
    private var mUpdateTimer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        var status = "Press Start";
        if (mSession != null && mSession.isRecording()) {
            status = "Recording";
        } else if (mSession != null) {
            status = "Stopped";
        }
        dc.drawText(width / 2, height * 15 / 100, Graphics.FONT_SMALL, status, Graphics.TEXT_JUSTIFY_CENTER);

        if (mSession != null && mSession.isRecording()) {
            var info = Activity.getActivityInfo();
            dc.drawText(width / 2, height * 38 / 100, Graphics.FONT_NUMBER_MEDIUM, formatTime(info.elapsedTime), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, height * 65 / 100, Graphics.FONT_MEDIUM, formatDistance(info.elapsedDistance), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, height * 85 / 100, Graphics.FONT_SMALL, formatSpeed(info.currentSpeed), Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    private function formatTime(elapsedMs as Number?) as String {
        if (elapsedMs == null) {
            return "0:00";
        }
        var totalSeconds = elapsedMs / 1000;
        var hours = totalSeconds / 3600;
        var minutes = (totalSeconds % 3600) / 60;
        var seconds = totalSeconds % 60;
        if (hours > 0) {
            return hours.format("%d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");
        }
        return minutes.format("%d") + ":" + seconds.format("%02d");
    }

    private function formatDistance(elapsedMeters as Float?) as String {
        if (elapsedMeters == null) {
            return "0.00 km";
        }
        return (elapsedMeters / 1000.0).format("%.2f") + " km";
    }

    private function formatSpeed(speedMps as Float?) as String {
        if (speedMps == null) {
            return "0.0 km/h";
        }
        return (speedMps * 3.6).format("%.1f") + " km/h";
    }

    function onHide() as Void {
        stopUpdateTimer();
    }

    function toggleRecording() as Void {
        if (mSession != null && mSession.isRecording()) {
            stopRecording();
        } else {
            startRecording();
        }
    }

    private function startRecording() as Void {
        mSession = ActivityRecording.createSession({
            :name => "Roller Ski",
            :sport => ActivityRecording.SPORT_CROSS_COUNTRY_SKIING
        });
        mSession.start();
        startUpdateTimer();
        WatchUi.requestUpdate();
    }

    private function stopRecording() as Void {
        if (mSession == null) {
            return;
        }
        mSession.stop();
        mSession.save();
        mSession = null;
        stopUpdateTimer();
        WatchUi.requestUpdate();
    }

    private function startUpdateTimer() as Void {
        if (mUpdateTimer == null) {
            mUpdateTimer = new Timer.Timer();
        }
        mUpdateTimer.start(method(:onTimerTick), 1000, true);
    }

    private function stopUpdateTimer() as Void {
        if (mUpdateTimer != null) {
            mUpdateTimer.stop();
        }
    }

    function onTimerTick() as Void {
        WatchUi.requestUpdate();
    }

}
