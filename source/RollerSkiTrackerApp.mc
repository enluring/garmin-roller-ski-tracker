import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

// Ski technique, chosen on-watch via the picker shown at the start of a
// session (see RollerSkiTrackerView.showSkiTypePicker /
// SkiTypePickerDelegate). Persisted as the "skiType" property.
module SkiType {
    const CLASSIC = 0;
    const SKATE = 1;
    const DOUBLE_POLING = 2;
}

// Application entry point. Owns the roller-ski activity recording session
// (started once a ski type is picked, stopped/saved on exit or via the
// delegate) and hands off to the initial view/delegate pair shown when the
// app is launched.
class RollerSkiTrackerApp extends Application.AppBase {

    private var _session as ActivityRecording.Session?;
    private var _sessionSaved as Boolean;
    private var _sessionStarted as Boolean;
    private var _skiType as Number;
    private var _intervalController as IntervalController?;
    private var _strokeDetector as StrokeDetector?;
    private var _strokeStats as StrokeStats?;
    private var _fitFieldWriter as FitFieldWriter?;

    function initialize() {
        AppBase.initialize();
        _sessionSaved = false;
        _sessionStarted = false;
        _skiType = SkiType.CLASSIC;
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
        stopAndSave();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new RollerSkiTrackerView(), new RollerSkiTrackerDelegate(self)];
    }

    // Called once, from the end of the ski-type/session-type/interval-setup
    // picker flow shown the first time the main view is shown. Persists the
    // ski type and starts the recording session; `intervalPlan` is null for
    // a free session, or a configured work/rest structure. No-op if a
    // session is already running.
    function beginSession(skiType as Number, intervalPlan as IntervalPlan?) as Void {
        if (_sessionStarted) {
            return;
        }

        _skiType = skiType;
        Properties.setValue("skiType", skiType);

        // Roller skiing has no dedicated Garmin sport profile, so this
        // records as a generic activity (see README).
        _session = ActivityRecording.createSession({
            :name => "Roller Ski",
            :sport => ActivityRecording.SPORT_GENERIC,
            :subSport => ActivityRecording.SUB_SPORT_GENERIC
        });
        _session.start();
        _sessionStarted = true;

        // Stroke detection starts reading the just-chosen skiType property
        // immediately, so it picks up the right axis/threshold from the
        // first sample.
        _strokeStats = new StrokeStats();
        _strokeDetector = new StrokeDetector();
        _fitFieldWriter = new FitFieldWriter(_session);

        if (intervalPlan != null) {
            _intervalController = new IntervalController(intervalPlan);
            _intervalController.setLapCallback(method(:onIntervalLap));
        }
    }

    function isSessionStarted() as Boolean {
        return _sessionStarted;
    }

    // Advances interval-phase tracking (lap marks + vibration cues) by one
    // tick. No-op for a free session, or before recording has started.
    function tickInterval() as Void {
        if (_intervalController == null || _session == null) {
            return;
        }
        var info = Activity.getActivityInfo();
        if (info == null || info.timerTime == null) {
            return;
        }
        _intervalController.tick(info.timerTime / 1000, _session);
    }

    // One-line interval status for the data screen ("WORK 2/4  01:23",
    // "INTERVAL DONE"), or null for a free session / before recording has
    // started.
    function getIntervalStatusText() as String? {
        if (_intervalController == null) {
            return null;
        }
        var info = Activity.getActivityInfo();
        if (info == null || info.timerTime == null) {
            return null;
        }
        return _intervalController.getStatusText(info.timerTime / 1000);
    }

    // Called from IntervalController on each interval phase transition, so
    // per-lap stroke stats roll over in step with the interval structure.
    function onIntervalLap() as Void {
        if (_strokeStats == null) {
            return;
        }
        var info = Activity.getActivityInfo();
        var elapsedDistanceM = (info != null) ? info.elapsedDistance : null;
        _strokeStats.onLapTurn(elapsedDistanceM);
        if (_fitFieldWriter != null) {
            _fitFieldWriter.onLapTurn(_strokeStats);
        }
    }

    // Polls the accelerometer-based stroke detector and updates stroke
    // stats / custom FIT fields. Call once per second while recording.
    // No-op for a session that hasn't started yet.
    function tickStrokes() as Void {
        if (_strokeDetector == null || _strokeStats == null || _session == null) {
            return;
        }

        var nowMs = System.getTimer();
        var count = _strokeDetector.getAndResetStrokeCount();
        _strokeStats.recordStrokes(count, nowMs);

        var info = Activity.getActivityInfo();
        var elapsedDistanceM = (info != null) ? info.elapsedDistance : null;
        _strokeStats.updateDistance(elapsedDistanceM);

        if (_fitFieldWriter != null) {
            _fitFieldWriter.update(_strokeStats);
        }
    }

    // Current (rolling-average) stroke rate in strokes/min, for display.
    function getCurrentStrokeRateSpm() as Float {
        return (_strokeStats != null) ? _strokeStats.getCurrentRateSpm() : 0.0;
    }

    // Session distance per stroke in meters, for display.
    function getSessionDistancePerStroke() as Float {
        return (_strokeStats != null) ? _strokeStats.getSessionDistancePerStroke() : 0.0;
    }

    function getSkiTypeLabel() as String {
        if (_skiType == SkiType.SKATE) {
            return "SKATE";
        } else if (_skiType == SkiType.DOUBLE_POLING) {
            return "DOUBLE POLING";
        }
        return "CLASSIC";
    }

    // Toggles between recording and paused. No-op before a ski type has
    // been picked (session not started yet) or once the session has been
    // stopped and saved.
    function toggleRecording() as Void {
        if (_session == null || _sessionSaved) {
            return;
        }
        if (_session.isRecording()) {
            _session.stop();
        } else {
            _session.start();
        }
    }

    // Stops (if still recording) and saves the session. Safe to call more
    // than once, and safe to call before a session has been started (e.g.
    // BACK pressed while the ski-type picker is still up).
    function stopAndSave() as Void {
        if (_session == null || _sessionSaved) {
            return;
        }
        if (_session.isRecording()) {
            _session.stop();
        }
        _session.save();
        _sessionSaved = true;
    }

    function isRecording() as Boolean {
        return (_session != null) && !_sessionSaved && _session.isRecording();
    }
}

function getApp() as RollerSkiTrackerApp {
    return Application.getApp() as RollerSkiTrackerApp;
}
