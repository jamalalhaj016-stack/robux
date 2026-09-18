#version 120
#include "/lib/common.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 vcolor;

/* DRAWBUFFERS:0 */
void main() {
    vec4 c = texture2D(texture, texcoord) * vcolor;
    if (c.a < 0.1) discard;
    gl_FragData[0] = vec4(toLinear(c.rgb), c.a);
}
