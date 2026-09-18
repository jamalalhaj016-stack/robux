#version 120
#include "/lib/common.glsl"
#include "/lib/sky.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 vcolor;

/* DRAWBUFFERS:0 */
void main() {
    // Sun and moon discs. Pushed well above 1.0 so the bloom pass has
    // something to catch.
    vec4 c = texture2D(texture, texcoord) * vcolor;
    c.rgb = toLinear(c.rgb) * 7.0 * (1.0 - rainStrength * 0.9);
    gl_FragData[0] = c;
}
