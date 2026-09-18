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
    // Diamond - cyan glow only on bright parts of texture (the diamonds)
    if (blockId == 50.0) {
        float brightness = dot(albedoColor, vec3(0.3, 0.6, 0.1));
        return vec3(0.3, 0.8, 1.0) * brightness * 0.6;
    }
    return vec3(0.0);
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

    // Add ore glow only where texture is bright (diamond bits, not stone)
    vec3 oreGlow = getOreGlow(vBlockId, albedo.rgb);
    color += oreGlow;

    gl_FragData[0] = vec4(color, albedo.a);
}
