#version 120
#include "/lib/common.glsl"

varying vec2 texcoord;
varying vec4 vcolor;
varying vec3 playerPos;

void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vcolor = gl_Color;
    playerPos = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;
}
