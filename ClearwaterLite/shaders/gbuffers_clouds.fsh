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

    // Complementary shader-style vibrant clouds
    vec3 sunColor = sunlightColor();
    vec3 skyColor = skyAmbientColor();

    // Rich, vibrant lighting
    vec3 light = sunColor * 1.1 + skyColor * 2.4;

    // Enhance cloud saturation and brightness
    c.rgb = c.rgb * light;
    c.rgb = c.rgb * 1.3; // Extra brightness

    // Smooth distance fade
    float distance = length(playerPos.xz);
    float fadeStart = max(far * 0.7, 60.0);
    float fadeEnd = max(far * 1.4, 120.0);
    float fade = smoothstep(fadeStart, fadeEnd, distance);

    // Blend with sky
    vec3 dir = normalize(playerPos);
    vec3 skyGradient = getSkyColor(dir);
    c.rgb = mix(c.rgb, skyGradient, fade * fade);

    gl_FragData[0] = c;
}
