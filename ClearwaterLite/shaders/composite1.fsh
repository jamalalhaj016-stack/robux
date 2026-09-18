#version 120
#include "/lib/common.glsl"
#include "/lib/blur.glsl"

uniform sampler2D colortex2;

varying vec2 texcoord;

/* DRAWBUFFERS:3 */
void main() {
#ifdef BLOOM
    vec2 dir = vec2(BLOOM_RADIUS / viewWidth, 0.0);
    gl_FragData[0] = vec4(blurAxis(colortex2, texcoord, dir), 1.0);
#else
    gl_FragData[0] = vec4(0.0);
#endif
}
