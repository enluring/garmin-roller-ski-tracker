import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

// Holds a configured work/rest interval structure: `rounds` repeats of
// `workSec` seconds of work followed by `restSec` seconds of rest (no rest
// after the final round). Immutable once created.
class IntervalPlan {
    var rounds;
    var workSec;
    var restSec;

    function initialize(rounds, workSec, restSec) {
        self.rounds = rounds;
        self.workSec = workSec;
        self.restSec = restSec;
    }
}

// Step after picking ski type: choose a free (open) session or a
// structured work/rest interval session. Chosen from
// SkiTypePickerDelegate.onSelect().
class SessionTypePickerDelegate extends WatchUi.Menu2InputDelegate {

    private var _skiType as Number;

    function initialize(skiType as Number) {
        Menu2InputDelegate.initialize();
        _skiType = skiType;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == :interval) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            pushRoundsPicker(_skiType);
        } else {
            getApp().beginSession(_skiType, null);
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

}

function pushSessionTypePicker(skiType as Number) as Void {
    var menu = new WatchUi.Menu2({:title => "Session type"});
    menu.addItem(new WatchUi.MenuItem("Free session", null, :free, null));
    menu.addItem(new WatchUi.MenuItem("Interval", null, :interval, null));
    WatchUi.pushView(menu, new SessionTypePickerDelegate(skiType), WatchUi.SLIDE_LEFT);
}

// --- Interval setup wizard: rounds -> work minutes -> rest minutes ---
//
// Each step replaces itself (pop, then push the next step) rather than
// stacking, so the view stack is always just [RollerSkiTrackerView,
// <current step>] and a single popView() reveals the main view again from
// any step's onAccept/onCancel. Canceling at any point falls back to a
// free (non-interval) session rather than leaving recording un-started.

function pushRoundsPicker(skiType as Number) as Void {
    var picker = new WatchUi.Picker({
        :title => new WatchUi.Text({
            :text => "Rounds",
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_TOP,
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_XTINY
        }),
        :pattern => [new WatchUi.NumberFactory(1, 20, 1, {:font => Graphics.FONT_NUMBER_MEDIUM})]
    });
    WatchUi.pushView(picker, new IntervalRoundsPickerDelegate(skiType), WatchUi.SLIDE_LEFT);
}

class IntervalRoundsPickerDelegate extends WatchUi.PickerDelegate {

    private var _skiType as Number;

    function initialize(skiType as Number) {
        PickerDelegate.initialize();
        _skiType = skiType;
    }

    function onCancel() as Boolean {
        getApp().beginSession(_skiType, null);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onAccept(values as Array) as Boolean {
        var rounds = values[0];
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        pushWorkMinutesPicker(_skiType, rounds);
        return true;
    }

}

function pushWorkMinutesPicker(skiType as Number, rounds as Number) as Void {
    var picker = new WatchUi.Picker({
        :title => new WatchUi.Text({
            :text => "Work (min)",
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_TOP,
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_XTINY
        }),
        :pattern => [new WatchUi.NumberFactory(1, 30, 1, {:font => Graphics.FONT_NUMBER_MEDIUM})]
    });
    WatchUi.pushView(picker, new IntervalWorkMinutesPickerDelegate(skiType, rounds), WatchUi.SLIDE_LEFT);
}

class IntervalWorkMinutesPickerDelegate extends WatchUi.PickerDelegate {

    private var _skiType as Number;
    private var _rounds as Number;

    function initialize(skiType as Number, rounds as Number) {
        PickerDelegate.initialize();
        _skiType = skiType;
        _rounds = rounds;
    }

    function onCancel() as Boolean {
        getApp().beginSession(_skiType, null);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onAccept(values as Array) as Boolean {
        var workMin = values[0];
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        pushRestMinutesPicker(_skiType, _rounds, workMin);
        return true;
    }

}

function pushRestMinutesPicker(skiType as Number, rounds as Number, workMin as Number) as Void {
    var picker = new WatchUi.Picker({
        :title => new WatchUi.Text({
            :text => "Rest (min)",
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_TOP,
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_XTINY
        }),
        :pattern => [new WatchUi.NumberFactory(0, 15, 1, {:font => Graphics.FONT_NUMBER_MEDIUM})]
    });
    WatchUi.pushView(picker, new IntervalRestMinutesPickerDelegate(skiType, rounds, workMin), WatchUi.SLIDE_LEFT);
}

class IntervalRestMinutesPickerDelegate extends WatchUi.PickerDelegate {

    private var _skiType as Number;
    private var _rounds as Number;
    private var _workMin as Number;

    function initialize(skiType as Number, rounds as Number, workMin as Number) {
        PickerDelegate.initialize();
        _skiType = skiType;
        _rounds = rounds;
        _workMin = workMin;
    }

    function onCancel() as Boolean {
        getApp().beginSession(_skiType, null);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onAccept(values as Array) as Boolean {
        var restMin = values[0];
        var plan = new IntervalPlan(_rounds, _workMin * 60, restMin * 60);
        getApp().beginSession(_skiType, plan);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

}
