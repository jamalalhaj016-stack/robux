#ifndef LIB_WAVING
#define LIB_WAVING

#include "/lib/sky.glsl"

/*
    Block ids come from block.properties:
      10 = water
      30 = small plants, anchored at the bottom
      31 = leaves
      32 = upper half of two-block plants, waves as a whole
*/

vec3 getWaveOffset(vec3 worldPos, float id, float isTopVertex, float skyLight) {
#if !defined WAVING_PLANTS && !defined WAVING_LEAVES
    return vec3(0.0);
#else
    if (id < 29.5 || id > 32.5) return vec3(0.0);

    float t = frameTimeCounter * WAVE_SPEED;

    // Slow travelling gust so the whole field breathes instead of every block
    // buzzing at the same rate.
    float gust = 0.55 + 0.45 * sin(t * 0.21 + (worldPos.x + worldPos.z) * 0.035);
    float amp  = WAVE_STRENGTH * gust
               * smoothstep(0.0, 0.35, skyLight)
               * (1.0 + rainStrength * 0.6);

    vec2 w = vec2(sin(t * 1.10 + worldPos.x * 0.70 + worldPos.z * 0.60),
                  cos(t * 0.93 + worldPos.x * 0.52 - worldPos.z * 0.81));

#ifdef WAVING_PLANTS
    if (id == 30.0) {
        // Only the vertices above the texture midpoint move, so the stalk
        // stays planted in the ground.
        float m = isTopVertex * amp * 0.055;
        return vec3(w.x, -abs(w.x) * 0.20, w.y * 0.70) * m;
    }
    if (id == 32.0) {
        float m = amp * 0.055;
        return vec3(w.x, -abs(w.x) * 0.20, w.y * 0.70) * m * (0.45 + 0.55 * isTopVertex);
    }
#endif

#ifdef WAVING_LEAVES
    if (id == 31.0) {
        float m = amp * 0.030;
        return vec3(w.x, w.y * 0.45, w.y) * m;
    }
#endif

    return vec3(0.0);
#endif
}

#endif
