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
    // Only glow if this is an ore block (ID 50)
    if (blockId != 50.0) return vec3(0.0);

    // Brightness threshold to detect ore bits (not stone)
    float brightness = max(max(albedoColor.r, albedoColor.g), albedoColor.b);
    if (brightness < 0.2) return vec3(0.0);

    // Analyze texture color to determine ore type and apply bright glow colors
    vec3 glowColor = vec3(0.0);

    // Gold/Copper - warm orange/yellow
    if (albedoColor.r > 0.5 && albedoColor.g > 0.3 && albedoColor.b < 0.4) {
        glowColor = vec3(1.0, 0.7, 0.2);
    }
    // Red/Redstone - bright red
    else if (albedoColor.r > 0.6 && albedoColor.g < 0.3 && albedoColor.b < 0.3) {
        glowColor = vec3(1.0, 0.2, 0.2);
    }
    // Green/Emerald - bright green
    else if (albedoColor.g > 0.5 && albedoColor.r < 0.5 && albedoColor.b < 0.4) {
        glowColor = vec3(0.2, 1.0, 0.3);
    }
    // Blue/Lapis - bright blue
    else if (albedoColor.b > 0.5 && albedoColor.r < 0.4 && albedoColor.g < 0.5) {
        glowColor = vec3(0.2, 0.4, 1.0);
    }
    // Cyan/Diamond - bright cyan
    else if (albedoColor.b > 0.4 && albedoColor.g > 0.4 && albedoColor.r < 0.5) {
        glowColor = vec3(0.3, 0.9, 1.0);
    }
    // Default - match ore color
    else {
        glowColor = albedoColor;
    }

    // Strong emissive glow
    return glowColor * brightness * 3.0;
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
