#ifndef LIB_SKY
#define LIB_SKY

#include "/lib/common.glsl"

/*
    One analytic sky function, shared by the sky pass, the fog in composite
    and the water reflections. Because all three read the same function the
    reflections always agree with the sky, which is most of what sells water
    without paying for screen space reflections.
*/

vec3 worldSunDir() {
    return normalize(mat3(gbufferModelViewInverse) * sunPosition);
}

vec3 worldMoonDir() {
    return normalize(mat3(gbufferModelViewInverse) * moonPosition);
}

// Points at whichever body is currently casting shadows.
vec3 worldShadowLightDir() {
    return normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
}

// 0 at night, 1 in full day, smooth across dawn/dusk.
float dayFactor() {
    return smoothstep(-0.06, 0.14, worldSunDir().y);
}

// 1 only while the sun sits near the horizon.
float sunsetFactor() {
    float h = worldSunDir().y;
    return (1.0 - smoothstep(0.0, 0.28, abs(h))) * smoothstep(-0.22, -0.02, h);
}

vec3 sunlightColor() {
    float sunset = sunsetFactor();
    vec3 day     = mix(vec3(1.00, 0.97, 0.90), vec3(1.00, 0.52, 0.24), sunset);
    vec3 night   = vec3(0.16, 0.24, 0.42) * 0.30;
    vec3 c       = mix(night, day, dayFactor());
    return c * (1.0 - rainStrength * 0.80) * SUN_INTENSITY;
}

vec3 skyZenithColor() {
    vec3 day   = vec3(0.075, 0.215, 0.520);
    vec3 night = vec3(0.006, 0.012, 0.038);
    vec3 c     = mix(night, day, dayFactor());
    c = mix(c, vec3(0.055, 0.065, 0.080), rainStrength * 0.85);
    return c * SKY_BRIGHTNESS;
}

vec3 skyHorizonColor() {
    float sunset = sunsetFactor();
    vec3 day     = mix(vec3(0.52, 0.70, 0.95), vec3(0.98, 0.45, 0.20), sunset);
    vec3 night   = vec3(0.022, 0.038, 0.082);
    vec3 c       = mix(night, day, dayFactor());
    c = mix(c, vec3(0.085, 0.095, 0.110), rainStrength * 0.85);
    return c * SKY_BRIGHTNESS;
}

// dir is a normalised world space direction, Y up.
vec3 getSkyColor(vec3 dir) {
    vec3 zenith  = skyZenithColor();
    vec3 horizon = skyHorizonColor();

    float h = saturate(dir.y * 0.5 + 0.5);
    float grad = pow(1.0 - saturate(dir.y), 5.0);
    vec3 sky = mix(zenith, horizon, grad);

    // Ground half: fade to a dimmer version of the horizon so the void and
    // anything below the fog line never turns into a hard seam.
    sky = mix(sky, horizon * 0.35, smoothstep(0.0, -0.35, dir.y));

    vec3 sunDir = worldSunDir();
    float sunCos = saturate(dot(dir, sunDir));

    // Broad forward scattering glow, then a tighter bloom near the disc.
    sky += sunlightColor() * pow(sunCos, 6.0) * 0.30 * (1.0 - rainStrength);
    sky += sunlightColor() * pow(sunCos, 64.0) * 0.55 * (1.0 - rainStrength);

    // Moon glow, much weaker.
    float moonCos = saturate(dot(dir, worldMoonDir()));
    sky += vec3(0.10, 0.14, 0.24) * pow(moonCos, 24.0) * 0.20 * (1.0 - dayFactor());

    return sky;
}

// Flat-ish ambient term for surfaces, derived from the same sky.
vec3 skyAmbientColor() {
    vec3 c = mix(skyZenithColor(), skyHorizonColor(), 0.45) * 0.62;
    // The raw night sky is far too dark to play under once albedo is squared,
    // so lift it with a small moonlit floor.
    c += vec3(0.020, 0.028, 0.050) * (1.0 - dayFactor());
    return c * AMBIENT_INTENSITY;
}

vec3 blocklightColor() {
    vec3 warm = vec3(1.00, 0.52, 0.20);
    vec3 neutral = vec3(1.00, 0.85, 0.70);
    return mix(neutral, warm, saturate(BLOCKLIGHT_TEMPERATURE)) * BLOCKLIGHT_INTENSITY;
}

#endif
