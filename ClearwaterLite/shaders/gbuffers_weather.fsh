#version 120
#include "/lib/common.glsl"
#include "/lib/sky.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vcolor;

/* DRAWBUFFERS:0 */
void main() {
    vec4 c = texture2D(texture, texcoord) * vcolor;
    if (c.a < 0.1) discard;

    vec3 light = skyAmbientColor() * (0.4 + 1.8 * lmcoord.y) + sunlightColor() * 0.20;
    c.rgb = toLinear(c.rgb) * light;
    c.a *= 0.75;

    gl_FragData[0] = c;
}
