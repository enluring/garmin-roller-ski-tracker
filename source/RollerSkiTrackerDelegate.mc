import Toybox.Lang;
import Toybox.WatchUi;

// Input handling for the main view. Will grow to handle starting/stopping
// the roller-ski activity recording session.
class RollerSkiTrackerDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        return true;
    }

}
