#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/lighting.glsl"

uniform sampler2D texture;

#ifdef PROGRAM_ENTITIES
uniform vec4 entityColor;
#endif

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vcolor;
varying vec3 wnormal;
varying vec3 playerPos;
varying float vBlockId;

vec3 getOreGlow(float blockId, vec3 albedoColor) {
    if (blockId != 50.0) return vec3(0.0);

    float brightness = max(max(albedoColor.r, albedoColor.g), albedoColor.b);
    if (brightness < 0.2) return vec3(0.0);

    // Simple smooth glow using texture color
    return albedoColor * brightness * 2.2;
}

void main() {
    vec4 albedo = texture2D(texture, texcoord) * vcolor;

#ifdef PROGRAM_ENTITIES
    albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);
#endif

    if (albedo.a < 0.1) discard;

    albedo.rgb = toLinear(albedo.rgb);

    float dither = bayer8(gl_FragCoord.xy);
    vec3 color = shadeSurface(albedo.rgb, normalize(wnormal), lmcoord, playerPos, dither);

    vec3 oreGlow = getOreGlow(vBlockId, albedo.rgb);
    color += oreGlow;

    gl_FragData[0] = vec4(color, albedo.a);
}
