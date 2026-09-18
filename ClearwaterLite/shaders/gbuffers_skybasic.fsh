#version 120
#include "/lib/common.glsl"
#include "/lib/sky.glsl"

varying vec3 viewPos;
varying vec4 starData;

/* DRAWBUFFERS:0 */
void main() {
    vec3 dir = normalize(mat3(gbufferModelViewInverse) * viewPos);
    vec3 color = getSkyColor(dir);

    if (starData.a > 0.5) {
        float s = starData.r;
        color += vec3(0.88, 0.93, 1.00) * s * s * 5.0
               * STARS_BRIGHTNESS * (1.0 - dayFactor()) * (1.0 - rainStrength);
    }

    gl_FragData[0] = vec4(color, 1.0);
}
