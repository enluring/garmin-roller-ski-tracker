import Toybox.Lang;
import Toybox.WatchUi;

// Handles the ski-type picker shown once, the first time
// RollerSkiTrackerView appears. Selecting an item stores the choice and
// starts the recording session (RollerSkiTrackerApp.beginSession), then
// dismisses the picker to reveal the main view underneath.
class SkiTypePickerDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        var skiType = SkiType.CLASSIC;
        if (id == :skate) {
            skiType = SkiType.SKATE;
        } else if (id == :doublePoling) {
            skiType = SkiType.DOUBLE_POLING;
        }

        getApp().beginSession(skiType);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}
