#version 120
#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/water.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;   // nearest surface, translucents included
uniform sampler2D depthtex1;   // nearest opaque surface

varying vec2 texcoord;

vec3 waterScatterColor() {
    return vec3(0.045, 0.140, 0.200) * (skyAmbientColor() * 3.0 + sunlightColor() * 0.35);
}

/* DRAWBUFFERS:02 */
void main() {
    vec3  color = texture2D(colortex0, texcoord).rgb;
    float d0 = texture2D(depthtex0, texcoord).x;
    float d1 = texture2D(depthtex1, texcoord).x;

    vec3  viewPos   = viewSpacePos(texcoord, d0, gbufferProjectionInverse);
    vec3  playerPos = mat3(gbufferModelViewInverse) * viewPos;
    vec3  dir  = normalize(playerPos);
    float dist = length(viewPos);
    bool  isSky = d0 >= 1.0;

    float waterFlag = texture2D(colortex1, texcoord).r;

    // How much water the light had to travel through to reach the camera.
    // depthtex0 is the water surface, depthtex1 the sea floor behind it.
    if (isEyeInWater == 0 && waterFlag > 0.5 && d1 > d0) {
        float thickness = max(linearizeDepth(d1, near, far) - linearizeDepth(d0, near, far), 0.0);
        vec3 absorb = exp(-waterExtinction() * thickness);
        color = color * absorb + waterScatterColor() * (1.0 - absorb);
    }

    if (isEyeInWater == 1) {
        float t = isSky ? far : min(dist, far);
        vec3 absorb = exp(-waterExtinction() * t * 1.2);
        color = color * absorb + waterScatterColor() * (1.0 - absorb);
    } else if (isEyeInWater == 2) {
        color = mix(color, vec3(0.90, 0.24, 0.03), saturate(dist * 0.7));
    }

#ifdef FOG
    if (isEyeInWater == 0 && !isSky) {
        float f = smoothstep(far * FOG_START, far * 0.97, dist);
        float rainFog = 1.0 - exp(-dist * 0.010 * rainStrength);
        f = saturate(max(f, rainFog) * FOG_DENSITY);
        // Fogging towards the sky in that direction rather than a flat colour
        // is what keeps distant terrain sitting in the scene.
        color = mix(color, getSkyColor(dir), f);
    }
#endif

    if (blindness > 0.0) color *= exp(-min(dist, far) * blindness * 0.45);

    vec3 bright = vec3(0.0);
#ifdef BLOOM
    float l = luma(color);
    bright = color * (max(l - BLOOM_THRESHOLD, 0.0) / max(l, 0.0001));
#endif

    gl_FragData[0] = vec4(color, 1.0);
    gl_FragData[1] = vec4(bright, 1.0);
}
