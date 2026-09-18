#version 120
#include "/lib/common.glsl"

varying vec3 viewPos;
varying vec4 starData;

void main() {
    gl_Position = ftransform();
    viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    // Stars are the only geometry in this pass drawn with a pure grey colour,
    // which is how we tell them apart from the sky and void planes.
    float isStar = float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0);
    starData = vec4(gl_Color.rgb, isStar);
}
