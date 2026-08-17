import Toybox.Lang;
import Toybox.WatchUi;

// Input handling for the main view: SELECT pauses/resumes the recording
// session, BACK stops and saves it (then falls through to the default
// exit behavior).
class RollerSkiTrackerDelegate extends WatchUi.BehaviorDelegate {

    private var _app as RollerSkiTrackerApp;

    function initialize(app as RollerSkiTrackerApp) {
        BehaviorDelegate.initialize();
        _app = app;
    }

    function onSelect() as Boolean {
        _app.toggleRecording();
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        _app.stopAndSave();
        return false;
    }

    function onMenu() as Boolean {
        return true;
    }

}
