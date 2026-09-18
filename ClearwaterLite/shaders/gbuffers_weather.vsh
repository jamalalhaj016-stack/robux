#version 120
#include "/lib/common.glsl"

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vcolor;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = remapLightmap((gl_TextureMatrix[1] * gl_MultiTexCoord1).xy);
    vcolor = gl_Color;
}
