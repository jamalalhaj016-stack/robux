#version 120
#include "/lib/common.glsl"

varying vec4 vcolor;

void main() {
    gl_Position = ftransform();
    vcolor = gl_Color;
}
