#ifndef LIB_SHADOW
#define LIB_SHADOW

#include "/lib/common.glsl"
#include "/lib/shadowdistort.glsl"

#ifdef SHADOWS
uniform sampler2DShadow shadowtex0;   // every caster, translucents included
uniform sampler2DShadow shadowtex1;   // opaque casters only

// With coloured shadows off we read the opaque-only map, so water and glass
// cast no shadow at all. That is both cheaper and better looking than letting
// them paint flat black patches on the sea floor.
#ifdef COLORED_SHADOWS
#define SHADOWMAP_MAIN shadowtex0
#else
#define SHADOWMAP_MAIN shadowtex1
#endif
#ifdef COLORED_SHADOWS
uniform sampler2D shadowcolor0;
#endif
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
#endif

/*
    Returns how much sunlight reaches the fragment, per channel.
    playerPos is world space relative to the camera.
*/
vec3 getSunVisibility(vec3 playerPos, vec3 worldNormal, float NdotL, float dither) {
#ifndef SHADOWS
    return vec3(1.0);
#else
    float dist = length(playerPos);
    float fade = smoothstep(shadowDistance * 0.78, shadowDistance * 0.96, dist);
    if (fade >= 1.0) return vec3(1.0);

    // Normal offset bias. Grazing angles need the most push, and the bias has
    // to grow with distance because distorted texels cover more world space.
    float bias = (0.045 + 0.20 * (1.0 - NdotL)) * (1.0 + dist * 0.012);
    vec3 offsetPos = playerPos + worldNormal * bias;

    vec4 clipPos = shadowProjection * (shadowModelView * vec4(offsetPos, 1.0));
    clipPos.xyz /= clipPos.w;

    float df = shadowDistortFactor(clipPos.xy);
    vec3 sp = distortShadowClip(clipPos.xyz) * 0.5 + 0.5;

    if (sp.x < 0.0 || sp.x > 1.0 || sp.y < 0.0 || sp.y > 1.0 || sp.z > 1.0) return vec3(1.0);

    sp.z -= 0.0006 * df;

    float radius = (SHADOW_SOFTNESS * df) / float(shadowMapResolution);

    float sumAll = 0.0;
    float sumOpaque = 0.0;

#if SHADOW_SAMPLES == 1
    sumAll    = shadow2D(SHADOWMAP_MAIN, sp).x;
    #ifdef COLORED_SHADOWS
    sumOpaque = shadow2D(shadowtex1, sp).x;
    #endif
#else
    // Golden angle spiral. Cheap to generate, no constant array needed, and
    // the per pixel dither rotation hides the low sample count.
    for (int i = 0; i < SHADOW_SAMPLES; i++) {
        float a = (float(i) + dither) * 2.39996323;
        float r = sqrt((float(i) + 0.5) / float(SHADOW_SAMPLES)) * radius;
        vec2 o = vec2(cos(a), sin(a)) * r;
        sumAll    += shadow2D(SHADOWMAP_MAIN, vec3(sp.xy + o, sp.z)).x;
        #ifdef COLORED_SHADOWS
        sumOpaque += shadow2D(shadowtex1, vec3(sp.xy + o, sp.z)).x;
        #endif
    }
    sumAll    /= float(SHADOW_SAMPLES);
    sumOpaque /= float(SHADOW_SAMPLES);
#endif

#ifdef COLORED_SHADOWS
    // Where the opaque-only map is lit but the full map is not, a translucent
    // block is in the way, so let its colour through instead of pure black.
    vec3 tint = texture2D(shadowcolor0, sp.xy).rgb;
    vec3 vis = vec3(sumAll) + max(sumOpaque - sumAll, 0.0) * tint;
#else
    vec3 vis = vec3(sumAll);
#endif

    return mix(vis, vec3(1.0), fade);
#endif
}

#endif
