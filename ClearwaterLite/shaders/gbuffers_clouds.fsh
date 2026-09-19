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

    // Complementary-style cloud rendering
    vec3 dir = normalize(playerPos);
    vec3 sunDir = worldShadowLightDir();

    // Rich cloud lighting - bright and vibrant
    vec3 sunLight = sunlightColor() * 1.3;
    vec3 skyLight = skyAmbientColor() * 2.8;
    vec3 rimLight = sunlightColor() * 0.5 * max(dot(dir, -sunDir), 0.0);

    // Cloud density affects lighting (thicker = darker)
    float cloudDensity = c.a;
    vec3 baseLighting = mix(skyLight * 0.5, sunLight, cloudDensity * 0.6);

    // Apply rich, saturated lighting
    c.rgb = c.rgb * (baseLighting + rimLight + skyLight * 0.4);

    // Beautiful distance fade
    float distance = length(playerPos.xz);
    float fadeDistance = max(far * 1.3, 90.0);
    float fade = smoothstep(fadeDistance * 0.5, fadeDistance, distance);

    // Blend smoothly with sky
    vec3 skyColor = getSkyColor(dir);
    c.rgb = mix(c.rgb, skyColor, fade);
    c.a = mix(c.a, 0.0, fade);

    gl_FragData[0] = c;
}
