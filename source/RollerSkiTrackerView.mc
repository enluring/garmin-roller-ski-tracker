import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Placeholder main screen. Will be replaced with the roller-ski specific
// data screen(s) (speed, distance, elevation gain, technique metrics, ...).
class RollerSkiTrackerView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_MEDIUM,
            "Roller Ski Tracker",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function onHide() as Void {
    }

}
