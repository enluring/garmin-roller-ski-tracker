import Toybox.Lang;
import Toybox.WatchUi;

// Input handling for the main view. Select toggles the roller-ski activity
// recording session start/stop.
class RollerSkiTrackerDelegate extends WatchUi.BehaviorDelegate {

    private var mView as RollerSkiTrackerView;

    function initialize(view as RollerSkiTrackerView) {
        BehaviorDelegate.initialize();
        mView = view;
    }

    function onSelect() as Boolean {
        mView.toggleRecording();
        return true;
    }

    function onMenu() as Boolean {
        return true;
    }

}
