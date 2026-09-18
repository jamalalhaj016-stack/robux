#version 120
#include "/lib/common.glsl"

varying vec4 vcolor;

/* DRAWBUFFERS:0 */
void main() {
    // Selection outlines and debug lines: unlit on purpose, they have to stay
    // readable in a dark cave.
    gl_FragData[0] = vec4(toLinear(vcolor.rgb), vcolor.a);
}
