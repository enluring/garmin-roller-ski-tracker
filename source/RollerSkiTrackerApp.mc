import Toybox.Application;
import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.WatchUi;

// Application entry point. Owns the roller-ski activity recording session
// (started on launch, stopped/saved on exit or via the delegate) and hands
// off to the initial view/delegate pair shown when the app is launched.
class RollerSkiTrackerApp extends Application.AppBase {

    private var _session as ActivityRecording.Session?;
    private var _sessionSaved as Boolean;

    function initialize() {
        AppBase.initialize();
        _sessionSaved = false;
    }

    function onStart(state as Dictionary?) as Void {
        // Roller skiing has no dedicated Garmin sport profile, so this
        // records as a generic activity (see README).
        _session = ActivityRecording.createSession({
            :name => "Roller Ski",
            :sport => ActivityRecording.SPORT_GENERIC,
            :subSport => ActivityRecording.SUB_SPORT_GENERIC
        });
        _session.start();
    }

    function onStop(state as Dictionary?) as Void {
        stopAndSave();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new RollerSkiTrackerView(), new RollerSkiTrackerDelegate(self)];
    }

    // Toggles between recording and paused. No-op once the session has been
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
    // than once - only the first call has any effect.
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
