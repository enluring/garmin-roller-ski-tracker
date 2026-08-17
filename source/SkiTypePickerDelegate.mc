import Toybox.Lang;
import Toybox.WatchUi;

// Handles the ski-type picker shown once, the first time
// RollerSkiTrackerView appears. Selecting an item replaces this menu with
// the session-type picker (SessionTypePickerDelegate, in
// IntervalSetup.mc), carrying the chosen ski type forward.
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

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        pushSessionTypePicker(skiType);
    }

}
