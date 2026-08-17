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
  strings/              Localized strings
  drawables/             Icons and images
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

Records a generic (`Toybox.ActivityRecording`) session, started on launch
and stopped/saved on exit, with a single data screen showing elapsed time,
distance, pace and heart rate. SELECT pauses/resumes recording; BACK stops,
saves and exits. Roller-ski specific technique metrics (stroke rate,
distance/stroke) are not part of this app - see the separate
`RollerskiTracker/` Connect IQ data field project for those.
