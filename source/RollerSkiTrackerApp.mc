import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.ActivityRecording;
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

    // Called once, from the ski-type picker shown the first time the main
    // view is shown. Persists the choice and starts the recording session.
    // No-op if a session is already running.
    function beginSession(skiType as Number) as Void {
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
    }

    function isSessionStarted() as Boolean {
        return _sessionStarted;
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
