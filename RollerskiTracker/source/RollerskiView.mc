import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.System;
import Toybox.Lang;

// The data field's single view. compute() pulls stroke counts and distance
// each tick and feeds StrokeStats / FitFieldWriter; onUpdate() renders two
// data views: a large central stroke-rate readout, and a smaller
// distance + distance/stroke row.
class RollerskiView extends WatchUi.DataField {

    private var _detector;
    private var _stats;
    private var _fitWriter;

    private var _rateSpm;
    private var _distanceM;
    private var _distPerStrokeM;

    function initialize() {
        DataField.initialize();

        _detector = new StrokeDetector();
        _stats = new StrokeStats();
        _fitWriter = new FitFieldWriter(self);

        _rateSpm = 0.0;
        _distanceM = 0.0;
        _distPerStrokeM = 0.0;
    }

    // Called from RollerskiApp.onSettingsChanged() so a ski-type or
    // threshold/axis change made in the Connect IQ phone app takes effect
    // immediately, without restarting the field.
    function refreshSettings() as Void {
        _detector.onSettingsChanged();
    }

    function onTimerReset() as Void {
        _stats.reset();
    }

    function onTimerLap() as Void {
        var info = Activity.getActivityInfo();
        var elapsedDistanceM = (info != null) ? info.elapsedDistance : null;
        _stats.onLapTurn(elapsedDistanceM);
        _fitWriter.onLapTurn(_stats);
    }

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        var nowMs = System.getTimer();

        var strokeCount = _detector.getAndResetStrokeCount();
        _stats.recordStrokes(strokeCount, nowMs);

        var elapsedDistanceM = info.elapsedDistance;
        _stats.updateDistance(elapsedDistanceM);

        _rateSpm = _stats.getCurrentRateSpm();
        _distanceM = (elapsedDistanceM != null) ? elapsedDistanceM : 0.0;
        _distPerStrokeM = _stats.getSessionDistancePerStroke();

        _fitWriter.update(_stats);

        return null;
    }

    // Picks a layout sized for the field's actual drawing area, so the same
    // field looks right whether placed as a large 1-field screen or a
    // smaller 2/3/4-field screen (two screen-size classes, per device).
    function onLayout(dc as Dc) as Boolean {
        var layout;
        if (dc.getHeight() >= 150) {
            layout = Rez.Layouts.MainLayoutLarge(dc);
        } else {
            layout = Rez.Layouts.MainLayoutSmall(dc);
        }
        View.setLayout(layout);
        return true;
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        setLabelText("RateValue", formatRate(_rateSpm));
        setLabelText("DistanceValue", formatDistance(_distanceM));
        setLabelText("DistPerStrokeValue", formatDistPerStroke(_distPerStrokeM));
    }

    private function setLabelText(id, text) {
        var drawable = View.findDrawableById(id);
        if (drawable != null) {
            drawable.setText(text);
        }
    }

    private function formatRate(spm) {
        return spm.format("%.0f");
    }

    private function formatDistance(meters) {
        if (meters >= 1000.0) {
            return (meters / 1000.0).format("%.2f") + " km";
        }
        return meters.format("%.0f") + " m";
    }

    private function formatDistPerStroke(meters) {
        return meters.format("%.1f") + " m";
    }
}
