import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Application entry point for the roller-ski data field. Owns the single
// RollerskiView instance and forwards Connect IQ mobile app setting changes
// (ski type, peak-detection thresholds/axes) to it.
class RollerskiApp extends Application.AppBase {

    private var _view as RollerskiView?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new RollerskiView();
        return [_view];
    }

    function onSettingsChanged() as Void {
        if (_view != null) {
            _view.refreshSettings();
        }
        WatchUi.requestUpdate();
    }
}

function getApp() as RollerskiApp {
    return Application.getApp() as RollerskiApp;
}
