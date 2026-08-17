import Toybox.Sensor;
import Toybox.System;
import Toybox.Application.Properties;
import Toybox.Lang;

// Ski technique, matching the "skiType" property (resources/properties).
module SkiType {
    const CLASSIC = 0;
    const SKATE = 1;
    const DOUBLE_POLING = 2;
}

// Accelerometer axis selector, matching the "axis*" properties.
module AccelAxis {
    const X = 0;
    const Y = 1;
    const Z = 2;
}

// Threshold-based peak detector for roller-ski pole strokes.
//
// Samples the accelerometer via Toybox.Sensor at SAMPLE_RATE_HZ and counts a
// stroke every time the configured axis crosses above the configured
// threshold, provided a refractory period has elapsed since the last
// detected stroke (debounces a single pole plant from registering twice).
//
// The axis and threshold used per ski type are NOT hardcoded here: they are
// read from Application.Properties (resources/properties/properties.xml,
// exposed to the user via resources/settings/settings.xml) so they can be
// recalibrated from the Connect IQ phone app after collecting real field
// data, without rebuilding the app. The shipped defaults are unvalidated
// placeholder starting points.
class StrokeDetector {

    private const SAMPLE_RATE_HZ = 25;
    private const REFRACTORY_MS = 300;

    private var _axis;
    private var _thresholdMg;
    private var _lastStrokeMs;
    private var _strokeCountSinceLastPoll;
    private var _aboveThreshold;

    function initialize() {
        _lastStrokeMs = 0;
        _strokeCountSinceLastPoll = 0;
        _aboveThreshold = false;

        loadConfig();

        Sensor.setEnabledSensors([Sensor.SENSOR_ACCELEROMETER]);
        Sensor.enableSensorEvents(method(:onSensorData));
        Sensor.setOptions({:accelerometer => {:enabled => true, :sampleRate => SAMPLE_RATE_HZ}});
    }

    // Call after Application.Properties may have changed (ski type switched,
    // or a threshold/axis recalibrated) so the detector picks up the new
    // config immediately, without an app restart.
    function onSettingsChanged() as Void {
        loadConfig();
    }

    private function loadConfig() {
        var skiType = Properties.getValue("skiType");
        if (skiType == null) {
            skiType = SkiType.CLASSIC;
        }

        if (skiType == SkiType.SKATE) {
            _axis = getProp("axisSkate", AccelAxis.Y);
            _thresholdMg = getProp("thresholdSkate", 1000);
        } else if (skiType == SkiType.DOUBLE_POLING) {
            _axis = getProp("axisDoublePoling", AccelAxis.Z);
            _thresholdMg = getProp("thresholdDoublePoling", 1400);
        } else {
            _axis = getProp("axisClassic", AccelAxis.Z);
            _thresholdMg = getProp("thresholdClassic", 1200);
        }

        // Avoid a stale "above threshold" latch tripping a spurious stroke
        // right after switching config (e.g. mid-swing when ski type changes).
        _aboveThreshold = false;
    }

    private function getProp(id, fallback) {
        var value = Properties.getValue(id);
        return (value != null) ? value : fallback;
    }

    // Sensor.enableSensorEvents callback. Fires periodically with a batch of
    // samples per enabled axis, collected since the previous call at
    // SAMPLE_RATE_HZ.
    function onSensorData(sensorInfo) {
        var samples = axisSamples(sensorInfo);
        if (samples == null) {
            return;
        }

        var n = samples.size();
        if (n == 0) {
            return;
        }

        var nowMs = System.getTimer();
        var msPerSample = 1000.0 / SAMPLE_RATE_HZ;

        // Samples in the batch are oldest-first; back-date each one from
        // "now" so refractory debouncing uses a real per-sample timestamp
        // rather than treating the whole batch as simultaneous.
        for (var i = 0; i < n; i += 1) {
            var sampleTimeMs = nowMs - ((n - 1 - i) * msPerSample).toNumber();
            var value = samples[i];

            if (value >= _thresholdMg) {
                if (!_aboveThreshold && (sampleTimeMs - _lastStrokeMs) >= REFRACTORY_MS) {
                    _strokeCountSinceLastPoll += 1;
                    _lastStrokeMs = sampleTimeMs;
                }
                _aboveThreshold = true;
            } else {
                _aboveThreshold = false;
            }
        }
    }

    private function axisSamples(sensorInfo) {
        if (sensorInfo == null) {
            return null;
        }
        if (_axis == AccelAxis.X) {
            return sensorInfo.accelerometerX;
        } else if (_axis == AccelAxis.Y) {
            return sensorInfo.accelerometerY;
        }
        return sensorInfo.accelerometerZ;
    }

    // Number of strokes detected since the last call; resets the counter.
    // Intended to be polled once per DataField.compute() tick.
    function getAndResetStrokeCount() as Number {
        var count = _strokeCountSinceLastPoll;
        _strokeCountSinceLastPoll = 0;
        return count;
    }
}
