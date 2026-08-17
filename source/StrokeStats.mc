import Toybox.System;
import Toybox.Lang;

// Aggregates stroke-rate and distance-per-stroke statistics, both for the
// whole session and per lap.
class StrokeStats {

    // Rolling window used to smooth the "current" stroke rate readout.
    // Shorter = more responsive but jumpier; longer = smoother but laggier.
    private const RATE_WINDOW_MS = 15000;

    private var _sessionStartMs;

    private var _totalStrokes;
    private var _lapStrokes;
    private var _lastLapStrokes;

    private var _sessionDistanceM;
    private var _lapStartDistanceM;
    private var _lastLapDistanceM;

    private var _lapStartMs;
    private var _lastLapDurationMs;

    // Timestamps (System.getTimer() ms) of strokes within the rolling
    // window, oldest first.
    private var _recentStrokeTimestamps;

    function initialize() {
        reset();
    }

    // Resets all totals. Call when a new session starts.
    function reset() as Void {
        var nowMs = System.getTimer();

        _sessionStartMs = nowMs;
        _totalStrokes = 0;
        _lapStrokes = 0;
        _lastLapStrokes = 0;

        _sessionDistanceM = 0.0;
        _lapStartDistanceM = 0.0;
        _lastLapDistanceM = 0.0;

        _lapStartMs = nowMs;
        _lastLapDurationMs = 0;

        _recentStrokeTimestamps = [];
    }

    // Record `count` new strokes detected at time `nowMs` (System.getTimer()).
    function recordStrokes(count, nowMs) as Void {
        if (count != null && count > 0) {
            _totalStrokes += count;
            _lapStrokes += count;

            for (var i = 0; i < count; i += 1) {
                _recentStrokeTimestamps.add(nowMs);
            }
        }

        pruneRecentStrokes(nowMs);
    }

    // Latest elapsed session distance in meters, typically from
    // Activity.Info.elapsedDistance.
    function updateDistance(elapsedDistanceM) as Void {
        if (elapsedDistanceM != null) {
            _sessionDistanceM = elapsedDistanceM;
        }
    }

    // Call when a new lap begins, passing the elapsed session distance at
    // the lap boundary.
    function onLapTurn(elapsedDistanceM) as Void {
        var nowMs = System.getTimer();

        _lastLapStrokes = _lapStrokes;
        _lastLapDistanceM = _sessionDistanceM - _lapStartDistanceM;
        _lastLapDurationMs = nowMs - _lapStartMs;

        _lapStrokes = 0;
        _lapStartDistanceM = (elapsedDistanceM != null) ? elapsedDistanceM : _sessionDistanceM;
        _lapStartMs = nowMs;
    }

    private function pruneRecentStrokes(nowMs) {
        var cutoffMs = nowMs - RATE_WINDOW_MS;
        var n = _recentStrokeTimestamps.size();
        var drop = 0;
        while (drop < n && _recentStrokeTimestamps[drop] < cutoffMs) {
            drop += 1;
        }
        if (drop > 0) {
            _recentStrokeTimestamps = _recentStrokeTimestamps.slice(drop, null);
        }
    }

    // --- Stroke rate (strokes per minute) ---

    // Rolling-average stroke rate over the last RATE_WINDOW_MS.
    function getCurrentRateSpm() as Float {
        var n = _recentStrokeTimestamps.size();
        if (n == 0) {
            return 0.0;
        }
        return (n.toFloat() / RATE_WINDOW_MS.toFloat()) * 60000.0;
    }

    // Average stroke rate across the whole session so far.
    function getSessionAvgRateSpm() as Float {
        var elapsedMs = System.getTimer() - _sessionStartMs;
        if (elapsedMs <= 0 || _totalStrokes == 0) {
            return 0.0;
        }
        return (_totalStrokes.toFloat() / elapsedMs.toFloat()) * 60000.0;
    }

    // Average stroke rate during the last completed lap.
    function getLastLapAvgRateSpm() as Float {
        if (_lastLapDurationMs <= 0 || _lastLapStrokes == 0) {
            return 0.0;
        }
        return (_lastLapStrokes.toFloat() / _lastLapDurationMs.toFloat()) * 60000.0;
    }

    // --- Distance per stroke (meters) ---

    function getSessionDistancePerStroke() as Float {
        if (_totalStrokes == 0) {
            return 0.0;
        }
        return _sessionDistanceM / _totalStrokes;
    }

    function getLapDistancePerStroke() as Float {
        if (_lapStrokes == 0) {
            return 0.0;
        }
        return (_sessionDistanceM - _lapStartDistanceM) / _lapStrokes;
    }

    function getLastLapDistancePerStroke() as Float {
        if (_lastLapStrokes == 0) {
            return 0.0;
        }
        return _lastLapDistanceM / _lastLapStrokes;
    }

    // --- Raw counters/totals, exposed for FitFieldWriter / the view ---

    function getTotalStrokes() as Number {
        return _totalStrokes;
    }

    function getLapStrokeCount() as Number {
        return _lapStrokes;
    }

    function getLastLapStrokeCount() as Number {
        return _lastLapStrokes;
    }

    function getSessionDistanceM() as Float {
        return _sessionDistanceM;
    }

    function getLastLapDistanceM() as Float {
        return _lastLapDistanceM;
    }
}
