import Toybox.FitContributor;
import Toybox.ActivityRecording;
import Toybox.Lang;

// Writes custom FIT fields via Toybox.FitContributor so stroke rate, lap
// stroke count and distance/stroke show up as named fields in Garmin
// Connect and other FIT analysis tools once the activity is saved.
class FitFieldWriter {

    private const FIELD_ID_STROKE_RATE = 0;
    private const FIELD_ID_AVG_STROKE_RATE = 1;
    private const FIELD_ID_LAP_STROKE_COUNT = 2;
    private const FIELD_ID_DISTANCE_PER_STROKE = 3;

    private var _strokeRateField;
    private var _avgStrokeRateField;
    private var _lapStrokeCountField;
    private var _distancePerStrokeField;

    // `owner` is the recording ActivityRecording.Session (createField() is
    // a FitContributor mixin method available on it).
    function initialize(owner as ActivityRecording.Session) {
        _strokeRateField = owner.createField(
            "stroke_rate",
            FIELD_ID_STROKE_RATE,
            FitContributor.DATA_TYPE_UINT16,
            {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "spm"}
        );
        _avgStrokeRateField = owner.createField(
            "avg_stroke_rate",
            FIELD_ID_AVG_STROKE_RATE,
            FitContributor.DATA_TYPE_UINT16,
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "spm"}
        );
        _lapStrokeCountField = owner.createField(
            "lap_stroke_count",
            FIELD_ID_LAP_STROKE_COUNT,
            FitContributor.DATA_TYPE_UINT16,
            {:mesgType => FitContributor.MESG_TYPE_LAP, :units => "strokes"}
        );
        _distancePerStrokeField = owner.createField(
            "distance_per_stroke",
            FIELD_ID_DISTANCE_PER_STROKE,
            FitContributor.DATA_TYPE_FLOAT,
            {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "m"}
        );

        _strokeRateField.setData(0);
        _avgStrokeRateField.setData(0);
        _lapStrokeCountField.setData(0);
        _distancePerStrokeField.setData(0.0);
    }

    // Call once per second with the latest StrokeStats.
    function update(stats) as Void {
        _strokeRateField.setData(stats.getCurrentRateSpm().toNumber());
        _avgStrokeRateField.setData(stats.getSessionAvgRateSpm().toNumber());
        _lapStrokeCountField.setData(stats.getLapStrokeCount());
        _distancePerStrokeField.setData(stats.getSessionDistancePerStroke().toFloat());
    }

    // Call when a lap turns over (before the LAP FIT message is written) so
    // lap_stroke_count reflects the just-finished lap's total, not the
    // reset-to-zero new lap.
    function onLapTurn(stats) as Void {
        _lapStrokeCountField.setData(stats.getLastLapStrokeCount());
    }
}
