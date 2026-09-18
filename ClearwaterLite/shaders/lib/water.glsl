#ifndef LIB_WATER
#define LIB_WATER

#include "/lib/sky.glsl"

/*
    A small stack of directional sine waves. No noise texture lookups, no
    parallax, no screen space reflections - all of the look comes from the
    normal plus a fresnel blend into the analytic sky.
*/

float waterWaveRaw(vec2 p) {
    float t = frameTimeCounter * WATER_WAVE_SPEED;

    float h = 0.0;
    float amp = 1.0;
    float norm = 0.0;
    float freq = 0.42;
    vec2 dir = normalize(vec2(0.85, 0.53));

    for (int i = 0; i <= WATER_DETAIL; i++) {
        h += sin(dot(p, dir) * freq + t * (0.9 + float(i) * 0.55)) * amp;
        norm += amp;
        amp *= 0.55;
        freq *= 2.10;
        dir = normalize(vec2(dir.y, -dir.x) + vec2(0.35, -0.20));
    }

    return (h / norm) * 0.16;
}

float waterDisplacement(vec2 p) {
#ifdef WATER_WAVES
    return waterWaveRaw(p) * WATER_WAVE_HEIGHT;
#else
    return 0.0;
#endif
}

// World space normal of the surface, Y up.
vec3 waterWaveNormal(vec2 p) {
#ifdef WATER_WAVES
    const float e = 0.10;
    float s  = WATER_NORMAL_STRENGTH;
    float h  = waterWaveRaw(p) * s;
    float hx = waterWaveRaw(p + vec2(e, 0.0)) * s;
    float hz = waterWaveRaw(p + vec2(0.0, e)) * s;
    return normalize(vec3(h - hx, e, h - hz));
#else
    return vec3(0.0, 1.0, 0.0);
#endif
}

float fresnelSchlick(float cosTheta, float f0) {
    float m = 1.0 - cosTheta;
    float m2 = m * m;
    return f0 + (1.0 - f0) * (m2 * m2 * m);
}

// Beer-Lambert extinction per metre of water travelled.
vec3 waterExtinction() {
    return vec3(0.38, 0.11, 0.07) * WATER_ABSORPTION;
}

#endif
