#version 120
#include "/lib/common.glsl"

varying vec2 texcoord;
varying vec4 vcolor;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vcolor = gl_Color;
}
