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

    c.rgb = toLinear(c.rgb);

    vec3 sunColor = sunlightColor();
    vec3 skyColor = skyAmbientColor();

    c.rgb = c.rgb * (sunColor * 2.0 + skyColor * 3.2);
    c.rgb = c.rgb * 1.8;

    float distance = length(playerPos.xz);
    float fadeStart = max(far * 0.6, 50.0);
    float fadeEnd = max(far * 1.5, 130.0);
    float fade = smoothstep(fadeStart, fadeEnd, distance);

    vec3 dir = normalize(playerPos);
    vec3 skyGradient = getSkyColor(dir);
    c.rgb = mix(c.rgb, skyGradient, fade * fade);

    gl_FragData[0] = c;
}
