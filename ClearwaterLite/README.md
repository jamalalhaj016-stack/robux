# Clearwater Lite

A Minecraft **Java Edition** shaderpack for **Iris / Oculus / OptiFine**, written for
GPUs that are a few generations old. Soft sun shadows, waving grass, an analytic sky
that drives the fog and the water reflections, and water with real waves, fresnel
reflections and depth-based absorption — without the features that usually eat the
frame budget on older cards.

## Installing (Oculus, on Forge)

1. Find your `shaderpacks` folder.
   - Vanilla launcher, Windows: press `Win+R`, type `%appdata%\.minecraft`, press Enter.
   - macOS: `~/Library/Application Support/minecraft`
   - Linux: `~/.minecraft`
   - CurseForge / Prism / MultiMC: open the instance folder instead — the button is
     usually **Open Folder** or **Browse** on the instance itself, then go into `.minecraft`.
   - If there is no `shaderpacks` folder yet, launch the game once with Oculus
     installed and it will be created for you.
2. Drop **`ClearwaterLite.zip`** into `shaderpacks`. Do not unzip it — Oculus reads the
   zip directly. (An unzipped folder works too, as long as the folder you copy in is the
   one that *contains* `shaders/`.)
3. Start Minecraft, then go to **Options → Video Settings → Shader Packs**.
4. Select **ClearwaterLite** in the list and back out of the menu.

OptiFine is the same, except the button is **Options → Video Settings → Shaders...**

Keep Rubidium / Embeddium installed alongside Oculus. It is the Forge port of Sodium and
it will do more for your frame rate than anything in this pack's settings.

## Pick a profile first

In the shader options screen there is a **Profile** button. Start there rather than
tuning individual settings:

| Profile | Roughly | What you get |
|---|---|---|
| **Potato** | integrated graphics, very old cards | No shadows, no bloom, flat water. Still gets you the sky, fog, water colour and tonemapping. |
| **Low** | GTX 750 Ti, HD 7770, older laptop chips | Hard-edged shadows at 512px, waving grass, waves without the sun glint. |
| **Medium** | GTX 1050 / 1060, RX 570, most ~2017-2018 cards | **Start here.** Soft shadows at 1024px, bloom, full water, waving leaves. |
| **High** | anything newer with frames to spare | 2048px shadows, 8-tap filtering, coloured shadows through stained glass. |

If Medium is choppy, drop to Low before you start turning off individual features.

## If you need more frames

Turn these off or down, in this order — it is roughly most-expensive-first:

1. **Shadows** (Shadows & Performance). By far the biggest cost. Off is a large jump.
2. **Shadow Resolution** → 512, and **Shadow Distance** → 48. Cheaper than disabling
   shadows outright, and 48 blocks of shadows still looks good.
3. **Shadow Filter** → 1. Hard edges, but nearly free.
4. **Bloom** (Colour & Bloom). Two fullscreen blur passes.
5. **Wave Detail** (Water) → 1.
6. **Waving Leaves** — cheap per vertex, but a forest has a great many vertices.

Your Minecraft **render distance** still matters more than any of these. Dropping from
16 to 10 chunks is usually a bigger win than every setting above combined.

## If it looks wrong

- **Too dark, or too bright** — Colour & Bloom → **Exposure**. This is the first knob to
  reach for; monitors vary a lot.
- **Caves are pitch black** — Lighting → **Minimum Light**, raise it a step or two.
- **Sunlight coming through walls** — raise **Shadow Distance**. Past that distance the
  pack falls back to Minecraft's own light values, which cannot see your roof.
- **Shadows look stripy on flat ground** — raise **Shadow Resolution** one step, or lower
  **Shadow Distance** so the same pixels cover less ground.
- **Water is too mirror-like** — Water → lower **Ripple Strength**, or raise
  **Water Opacity** to see more of the bottom.
- **Grass tears away from the ground** — lower **Wind Strength**.

## What is inside

```
shaders/
  gbuffers_*        terrain, entities, hand, sky, clouds, weather, water
  shadow.vsh/fsh    the sun and moon shadow map
  composite*.fsh    water absorption, fog, bloom blur
  final.fsh         tonemapping, colour grading, vignette
  lib/              shared code: sky model, lighting, shadows, waves
  shaders.properties, block.properties, lang/
```

Design notes, since they explain the settings:

- **Forward lighting.** Surfaces are lit in the gbuffer pass rather than in a deferred
  pass, so the g-buffer is a single render target instead of a packed normal and material
  stack. On a card with narrow memory bandwidth that is the largest single win available.
- **One sky function.** The sky pass, the fog and the water reflections all call the same
  `getSkyColor()`. Reflections therefore always agree with the sky without tracing
  anything in screen space.
- **Gamma 2.0, not 2.2.** Albedo is squared and the final image square-rooted. Two
  instructions instead of a `pow`, for a hue shift nobody will notice.
- **Stable dithering.** The shadow filter kernel is rotated by an ordered Bayer pattern
  rather than per-frame noise, so low sample counts stay quiet instead of sparkling.
- **No normal mapping, no parallax, no SSAO, no SSR, no mip pyramid.** These are the
  features that would cost the most here and they are deliberately absent.
- **GLSL 120** throughout, which is the dialect with the widest driver support.

## Editing it

Every user-facing setting lives in `shaders/lib/settings.glsl`, with its slider values in
the `// [ ... ]` comment beside it. `shaders/shaders.properties` controls the menu layout
and the profiles, and `shaders/lang/en_us.lang` holds the names and tooltips.

Run `./build.sh` to repack `ClearwaterLite.zip` after changing anything.

## Compatibility

Aimed at Iris, Oculus and OptiFine. Every program compiles cleanly under `glslangValidator`
in all four profiles, but **this has not been run inside Minecraft on a real driver** —
please treat the first launch as the real test. If a program fails to load, Oculus will
say which one in the game log (`.minecraft/logs/latest.log`); that log line is the useful
thing to report.
