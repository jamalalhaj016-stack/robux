#version 120
#include "/lib/common.glsl"
#include "/lib/sky.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 vcolor;
varying vec3 playerPos;

/* DRAWBUFFERS:0 */
void main() {
    vec4 c = texture2D(texture, texcoord) * vcolor;
    if (c.a < 0.1) discard;

    c.rgb = toLinear(c.rgb) * (sunlightColor() * 0.55 + skyAmbientColor() * 1.6);

    // Melt the far edge of the cloud plane into the sky instead of ending it
    // on a hard line.
    float fade = saturate(length(playerPos.xz) / max(far * 1.6, 96.0));
    c.rgb = mix(c.rgb, getSkyColor(normalize(playerPos)), fade * fade);

    gl_FragData[0] = c;
}
