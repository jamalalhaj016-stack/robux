#ifndef LIB_SHADOWDISTORT
#define LIB_SHADOWDISTORT

#include "/lib/settings.glsl"

/*
    Shared by shadow.vsh and the lighting pass. Both sides must agree
    exactly or shadows detach from their casters.
*/

float shadowDistortFactor(vec2 p) {
    return length(p) * SHADOW_DISTORTION + (1.0 - SHADOW_DISTORTION);
}

vec3 distortShadowClip(vec3 p) {
    p.xy /= shadowDistortFactor(p.xy);
    p.z *= 0.5;              // compress depth range, keeps bias sane
    return p;
}

#endif
