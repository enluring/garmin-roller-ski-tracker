import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Application entry point. Owns app-wide lifecycle and hands off to the
// initial view/delegate pair shown when the app is launched.
class RollerSkiTrackerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new RollerSkiTrackerView(), new RollerSkiTrackerDelegate()];
    }

}

function getApp() as RollerSkiTrackerApp {
    return Application.getApp() as RollerSkiTrackerApp;
}
