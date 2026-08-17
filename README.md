# Roller Ski Tracker

A Garmin Connect IQ watch app specialized for the roller skiing (rollerski)
activity. It records a standalone activity session and is intended to surface
metrics and screens tailored to roller skiing, which is not natively
supported as a distinct sport profile on Garmin devices.

Target device(s): Forerunner 265 / 265S.

## Tech stack

- **Language:** [Monkey C](https://developer.garmin.com/connect-iq/monkey-c/),
  Garmin's proprietary language for Connect IQ apps.
- **SDK:** [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- **Editor:** [Visual Studio Code](https://code.visualstudio.com/) with the
  official [Monkey C extension](https://marketplace.visualstudio.com/items?itemName=garmin.monkey-c)

## Project layout

```text
manifest.xml            Application manifest (id, target devices, permissions)
monkey.jungle           Build configuration (source/resource sets per device)
source/                 Monkey C source files
resources/
  strings/               Localized strings
  drawables/             Icons and images
  properties/            Application.Properties definitions/defaults (skiType, stroke thresholds/axes)
  settings/              Phone-app settings screen (stroke threshold/axis calibration)
```

## Prerequisites

1. **Java Runtime** 8 or higher (required by the SDK toolchain).
2. **VS Code** with the **Monkey C** extension installed
   (`garmin.monkey-c` in the Marketplace).
3. Use the extension's SDK Manager (Command Palette → `Monkey C: Show
   Connect IQ Devices`/`Monkey C: Download Current SDK`) to install the
   Connect IQ SDK and the Forerunner 265/265S device simulator assets.
4. Generate a developer signing key (Command Palette →
   `Monkey C: Generate a Developer Key`). This key is your app's identity
   and **must never be committed** — it is already excluded via
   `.gitignore`.

## Build & run

1. Open this folder in VS Code.
2. Command Palette → `Monkey C: Build Current Project` (or press the Run
   button) to compile.
3. Command Palette → `Monkey C: Run Current Project in Simulator`, then pick
   Forerunner 265 or 265S as the target device.

## Status

On launch, walks through an on-watch setup flow before recording starts:

1. **Ski type** - classic / skate / double poling (stored as the `skiType`
   property, shown at the top of the data screen).
2. **Session type** - free (open) session, or **interval**: choose number
   of rounds, work minutes and rest minutes via number pickers (mirrors the
   built-in Run app's on-device interval setup).

Once configured, records a generic (`Toybox.ActivityRecording`) session and
starts accelerometer-based stroke detection (`StrokeDetector`, 25 Hz,
threshold peak detection with a 300ms refractory debounce). The data screen
is a 2-column grid: time/distance, pace/heart rate, and stroke
rate/distance-per-stroke (`StrokeStats`), with custom FIT fields for all of
it written via `FitFieldWriter` (`Toybox.FitContributor`) so they show up
in Garmin Connect after sync. The peak-detection axis and threshold used
per ski type are **not hardcoded** - they're `Application.Properties`
(`resources/properties/properties.xml`), editable from the Connect IQ phone
app (`resources/settings/settings.xml`) without rebuilding; the shipped
defaults are unvalidated placeholders pending field calibration.

For an interval session, `IntervalController` derives the current work/rest
phase from elapsed active time each second, shows it on the data screen
("WORK 2/4  01:23"), marks a FIT lap (rolling over per-lap stroke stats too)
and vibrates on every phase change, and switches to "INTERVAL DONE" once all
rounds are complete (recording continues as a normal free session after
that). SELECT pauses/resumes recording; BACK stops, saves and exits.

There is also a separate `RollerskiTracker/` Connect IQ **data field**
project in this repo, with its own copy of the stroke-detection logic and
its own `skiType` property (phone-settings only, no on-watch picker). It
exists so the stroke metrics can be added as a field inside Garmin's
built-in activity apps (Run, Bike, etc.) - something a standalone watchApp
like this one cannot host. The two projects have separate app IDs and do
not share properties or code; keeping their calibration values in sync
(and picking the app to launch based on whether you want interval
setup/HR/pace vs. embedding into a built-in app) is a manual step.
