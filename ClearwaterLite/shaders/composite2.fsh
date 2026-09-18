#version 120
#include "/lib/common.glsl"
#include "/lib/blur.glsl"

uniform sampler2D colortex3;

varying vec2 texcoord;

/* DRAWBUFFERS:2 */
void main() {
#ifdef BLOOM
    vec2 dir = vec2(0.0, BLOOM_RADIUS / viewHeight);
    gl_FragData[0] = vec4(blurAxis(colortex3, texcoord, dir), 1.0);
#else
    gl_FragData[0] = vec4(0.0);
#endif
}
