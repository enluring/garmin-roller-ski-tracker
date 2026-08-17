import Toybox.Lang;
import Toybox.ActivityRecording;
import Toybox.Attention;

module IntervalPhase {
    const WORK = 0;
    const REST = 1;
    const DONE = 2;
}

// Derives the current work/rest phase from elapsed *active* session time
// (Activity.Info.timerTime, which excludes paused time), rather than
// counting down its own timer - so the phase is always correct even if the
// view was hidden for a while and missed some ticks. Marks a FIT lap and
// fires a vibration cue exactly once on each phase transition.
class IntervalController {

    private var _plan as IntervalPlan;
    private var _lastPhase as Number;
    private var _lastRound as Number;

    function initialize(plan as IntervalPlan) {
        _plan = plan;
        _lastPhase = -1;
        _lastRound = -1;
    }

    // Call once per second (while a session is recording) with the
    // session's elapsed active time in seconds, e.g.
    // Activity.Info.timerTime / 1000.
    function tick(elapsedActiveSec as Number, session as ActivityRecording.Session?) as Void {
        var status = computeStatus(elapsedActiveSec);

        if (status[:phase] != _lastPhase || status[:round] != _lastRound) {
            onPhaseChanged(status, session);
            _lastPhase = status[:phase];
            _lastRound = status[:round];
        }
    }

    private function onPhaseChanged(status as Dictionary, session as ActivityRecording.Session?) as Void {
        // Skip the lap mark on the very first tick - round 1's work phase
        // already starts at the session's own start, no separate lap needed.
        if (_lastPhase != -1 && session != null && session.isRecording()) {
            session.addLap();
        }

        if (Attention has :vibrate) {
            if (status[:phase] == IntervalPhase.WORK) {
                Attention.vibrate([new Attention.VibeProfile(100, 500)]);
            } else if (status[:phase] == IntervalPhase.REST) {
                Attention.vibrate([
                    new Attention.VibeProfile(50, 200),
                    new Attention.VibeProfile(0, 150),
                    new Attention.VibeProfile(50, 200)
                ]);
            }
        }
    }

    private function computeStatus(elapsedActiveSec as Number) as Dictionary {
        var remaining = elapsedActiveSec;

        for (var round = 1; round <= _plan.rounds; round += 1) {
            if (remaining < _plan.workSec) {
                return {:phase => IntervalPhase.WORK, :round => round, :remainingSec => _plan.workSec - remaining};
            }
            remaining -= _plan.workSec;

            var isLastRound = (round == _plan.rounds);
            if (!isLastRound) {
                if (remaining < _plan.restSec) {
                    return {:phase => IntervalPhase.REST, :round => round, :remainingSec => _plan.restSec - remaining};
                }
                remaining -= _plan.restSec;
            }
        }

        return {:phase => IntervalPhase.DONE, :round => _plan.rounds, :remainingSec => 0};
    }

    // Human-readable one-line status for the data screen, e.g.
    // "WORK 2/4  01:23" or "INTERVAL DONE".
    function getStatusText(elapsedActiveSec as Number) as String {
        var status = computeStatus(elapsedActiveSec);

        if (status[:phase] == IntervalPhase.DONE) {
            return "INTERVAL DONE";
        }

        var phaseLabel = (status[:phase] == IntervalPhase.WORK) ? "WORK" : "REST";
        var remainingSec = status[:remainingSec];
        var minutes = remainingSec / 60;
        var seconds = remainingSec % 60;

        return phaseLabel + " " + status[:round] + "/" + _plan.rounds + "  " + minutes.format("%d") + ":" + seconds.format("%02d");
    }

}
