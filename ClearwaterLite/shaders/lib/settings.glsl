#ifndef LIB_SETTINGS
#define LIB_SETTINGS

/*
    Clearwater Lite - user settings.
    Everything in here is exposed in Video Settings -> Shaders -> Shader Options.
*/

/* ------------------------------ Shadows ------------------------------ */

#define SHADOWS                               // Sun and moon shadow mapping.
const int   shadowMapResolution   = 1024;     // [512 768 1024 1536 2048 3072]
const float shadowDistance        = 96.0;     // [32.0 48.0 64.0 96.0 128.0 192.0]
#define SHADOW_SAMPLES 4                      // [1 4 8 16]
#define SHADOW_SOFTNESS 1.0                   // [0.5 1.0 1.5 2.5 4.0]
//#define COLORED_SHADOWS                     // Stained glass / water tints the shadow. Costs 1 extra tap.
const float sunPathRotation       = -25.0;    // [-50.0 -40.0 -30.0 -25.0 -20.0 -10.0 0.0 10.0 20.0 25.0 30.0 40.0]

#define SHADOW_DISTORTION 0.85
const bool shadowHardwareFiltering = true;

/* ------------------------------ Lighting ----------------------------- */

#define SUN_INTENSITY 1.55            // [0.8 1.0 1.25 1.55 1.8 2.2]
#define AMBIENT_INTENSITY 1.0         // [0.5 0.75 1.0 1.25 1.5]
#define BLOCKLIGHT_INTENSITY 1.0      // [0.5 0.75 1.0 1.5 2.0]
#define BLOCKLIGHT_TEMPERATURE 1.0    // [0.0 0.5 1.0 1.5]
#define MINIMUM_LIGHT 0.015           // [0.0 0.008 0.015 0.03 0.06]
#define HANDHELD_LIGHT                // Torches in your hand light the world.

/* ------------------------------- Water ------------------------------- */

#define WATER_WAVES
#define WATER_WAVE_HEIGHT 1.0     // [0.0 0.5 0.75 1.0 1.5 2.0]
#define WATER_WAVE_SPEED 1.0      // [0.5 0.75 1.0 1.5 2.0]
#define WATER_DETAIL 2            // [1 2 3]
#define WATER_NORMAL_STRENGTH 1.0 // [0.25 0.5 1.0 1.5 2.5]
#define WATER_SPECULAR            // Sharp sun/moon glint on the water.
#define WATER_OPACITY 0.30        // [0.10 0.20 0.30 0.45 0.60]
#define WATER_ABSORPTION 1.0      // [0.5 0.75 1.0 1.5 2.0]

/* --------------------------- Waving world ---------------------------- */

#define WAVING_PLANTS
#define WAVING_LEAVES
#define WAVE_SPEED 1.0            // [0.5 0.75 1.0 1.5 2.0]
#define WAVE_STRENGTH 1.0         // [0.5 0.75 1.0 1.5 2.0]

/* ----------------------------- Atmosphere ---------------------------- */

#define FOG
#define FOG_DENSITY 1.0           // [0.0 0.5 0.75 1.0 1.5 2.0]
#define FOG_START 0.55            // [0.2 0.35 0.55 0.75 0.9]
#define SKY_BRIGHTNESS 1.0        // [0.6 0.8 1.0 1.25 1.5]
#define STARS_BRIGHTNESS 1.0      // [0.0 0.5 1.0 1.5 2.5]

/* ------------------------------- Post -------------------------------- */

#define BLOOM
#define BLOOM_STRENGTH 0.35       // [0.1 0.2 0.35 0.5 0.75 1.0]
#define BLOOM_RADIUS 1.0          // [0.5 1.0 1.5 2.0]
#define BLOOM_THRESHOLD 0.65      // [0.35 0.5 0.65 0.8 1.0]
#define EXPOSURE 1.0              // [0.6 0.8 0.9 1.0 1.1 1.25 1.5]
#define SATURATION 1.08           // [0.8 0.9 1.0 1.08 1.2 1.35]
#define CONTRAST 1.04             // [0.9 1.0 1.04 1.1 1.2]
#define VIGNETTE
#define VIGNETTE_STRENGTH 0.35    // [0.15 0.25 0.35 0.5 0.75]

/* ---------------------------- Buffer setup ---------------------------
    Parsed by OptiFine/Iris out of this comment block.

    colortex0 - HDR scene colour
    colortex1 - translucent material flags (r = water)
    colortex2 - bloom source / final bloom
    colortex3 - bloom ping-pong

const int colortex0Format = RGBA16F;
const int colortex1Format = RGBA8;
const int colortex2Format = RGB16F;
const int colortex3Format = RGB16F;

const vec4 colortex1ClearColor = vec4(0.0, 0.0, 0.0, 0.0);
----------------------------------------------------------------------- */

const float ambientOcclusionLevel = 1.0; // [0.0 0.25 0.5 0.75 1.0]

#endif
