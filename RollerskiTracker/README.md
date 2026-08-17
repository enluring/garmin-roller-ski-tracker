# RollerskiTracker

Connect IQ **data field** (not a standalone app) for roller-ski pole-stroke
tracking: stroke rate, distance per stroke, and custom FIT fields, tuned
per ski type (classic / skate / double poling).

Targets: fenix7, fr965, fr265 (adjust `<iq:products>` in `manifest.xml` for
other devices).

## Build & run

Open this `RollerskiTracker/` folder (not the repo root) in VS Code so the
Monkey C extension picks up its `manifest.xml`. Then use `Monkey C: Build
Current Project` / `Monkey C: Run Current Project in Simulator`, add the
field to an activity's data screen in the simulator, and start a
(simulated) activity.

## Calibration procedure

Peak-detection axis and threshold are **not hardcoded** — they're
`Application.Properties`, one set per ski type, editable from the Connect
IQ mobile app without rebuilding:

| Property | Meaning | Shipped default |
|---|---|---|
| `axisClassic` / `axisSkate` / `axisDoublePoling` | Accelerometer axis to watch (0=X, 1=Y, 2=Z) | Z, Y, Z |
| `thresholdClassic` / `thresholdSkate` / `thresholdDoublePoling` | Peak threshold, in mg (milli-g) | 1200, 1000, 1400 |

These defaults are **unvalidated placeholders**, not measured values. To
calibrate them from field data:

1. **Record a reference session.** Add the RollerskiTracker field to a data
   screen, start an activity, and ski a short, steady interval (e.g. 30–60s)
   of one technique (classic, skate, or double poling) with a known,
   manually-counted number of pole strokes.
2. **Save and export the FIT file** (Garmin Connect → activity → export
   original `.FIT`), then inspect it with a FIT viewer/analysis tool (e.g.
   [FIT File Viewer](https://www.fitfileviewer.com/), Garmin's FIT SDK
   tools, or `fitdump`/`fitparse`). Look at:
   - The `lap_stroke_count` / `distance_per_stroke` custom fields this
     field writes, vs. your manual count for that interval.
   - If you have raw accelerometer logging enabled separately, the
     X/Y/Z traces around each known pole plant, to see which axis shows
     the cleanest, most consistent peak and roughly how high it goes (in
     mg) relative to the noise floor.
3. **Adjust the property for that ski type**, on your phone: Garmin Connect
   Mobile → device → **RollerskiTracker** field settings → pick the ski
   type's axis/threshold. Raise the threshold if strokes are
   over-counted (noise/vibration triggering false peaks); lower it if
   under-counted (real pole plants not crossing the threshold). Switch
   axis if another one shows a cleaner signal for that technique.
4. **Repeat** with a fresh short recording until the detected stroke count
   for the interval matches your manual count closely, then repeat steps
   1–4 for the other two ski types — classic and skate in particular tend
   to need different axis/threshold pairs (see `StrokeDetector.mc`).
5. Note down the values that worked (device, ski type, axis, threshold) so
   they can be set as the new shipped defaults in
   `resources/properties/properties.xml` for future installs.

No rebuild is required for steps 1–4; only step 5 (updating the shipped
defaults) touches the source tree.
