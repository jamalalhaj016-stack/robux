#ifndef LIB_LIGHTING
#define LIB_LIGHTING

#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/shadow.glsl"

vec3 handheldLight(vec3 playerPos) {
#ifdef HANDHELD_LIGHT
    float held = float(max(heldBlockLightValue, heldBlockLightValue2)) / 15.0;
    if (held <= 0.0) return vec3(0.0);
    float d = length(playerPos);
    return blocklightColor() * min(held * 6.0 / (1.0 + d * d), 1.1);
#else
    return vec3(0.0);
#endif
}

/*
    Forward shading. Every opaque surface is lit here rather than in a deferred
    pass: it keeps the g-buffer down to one render target, which is the single
    biggest win on a card with narrow memory bandwidth.

    albedo must already be linear, playerPos is world space relative to camera.
*/
vec3 shadeSurface(vec3 albedo, vec3 N, vec2 lm, vec3 playerPos, float dither) {
    vec3 L = worldShadowLightDir();
    float diffuse = max(dot(N, L), 0.0);

    vec3 vis = vec3(0.0);
    if (diffuse > 0.0) {
        vis = getSunVisibility(playerPos, N, diffuse, dither);
    }

    // The shadow map only reaches so far, and it cannot see through a ceiling
    // beyond that. Gating on the sky lightmap stops sun leaking indoors.
    float skyMask = smoothstep(0.12, 0.42, lm.y);

    vec3 direct = sunlightColor() * diffuse * vis * skyMask;

    // Hemispheric ambient: upward faces catch more sky than downward ones.
    vec3 ambient = skyAmbientColor() * (0.10 + 0.90 * lm.y) * (0.72 + 0.28 * N.y);

    vec3 block = blocklightColor() * pow(lm.x, 2.6) * 1.4 + handheldLight(playerPos);

    return albedo * (direct + ambient + block + MINIMUM_LIGHT);
}

#endif
