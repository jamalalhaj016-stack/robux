#version 120
#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/water.glsl"
#include "/lib/lighting.glsl"

uniform sampler2D texture;

varying vec2  texcoord;
varying vec2  lmcoord;
varying vec4  vcolor;
varying vec3  wnormal;
varying vec3  playerPos;
varying float isWater;

/* DRAWBUFFERS:01 */
void main() {
    vec4 albedo = texture2D(texture, texcoord) * vcolor;
    if (albedo.a < 0.02) discard;
    albedo.rgb = toLinear(albedo.rgb);

    float dither  = bayer8(gl_FragCoord.xy);
    vec3  N       = normalize(wnormal);
    vec3  viewDir = normalize(playerPos);       // camera -> fragment, world space

    vec3  color;
    float alpha;

    if (isWater > 0.5) {
        if (!gl_FrontFacing) N = -N;

        // Ripple normal, top faces only - the sides of a water block are
        // vertical quads and a wave normal there just looks wrong.
        vec3 waveN = N;
        if (abs(N.y) > 0.5) {
            vec3 w = waterWaveNormal((playerPos + cameraPosition).xz);
            waveN = normalize(vec3(w.x, w.y * sign(N.y), w.z));
        }

        float NdotV   = saturate(dot(waveN, -viewDir));
        float fresnel = fresnelSchlick(NdotV, 0.02);

        // Reflection straight out of the same analytic sky the sky pass uses,
        // so it always matches without a screen space trace.
        vec3 reflDir = reflect(viewDir, waveN);
        reflDir.y = abs(reflDir.y);
        vec3 reflection = getSkyColor(reflDir) * (0.30 + 0.70 * lmcoord.y);

        // Body of the water: the vanilla texture keeps the biome tint.
        vec3 body = shadeSurface(albedo.rgb * 0.30, waveN, lmcoord, playerPos, dither);

        vec3 specular = vec3(0.0);
#ifdef WATER_SPECULAR
        vec3 L = worldShadowLightDir();
        float NdotL = saturate(dot(waveN, L));
        vec3 H = normalize(L - viewDir);
        float s = pow(saturate(dot(waveN, H)), 200.0);
        specular = sunlightColor() * s * 14.0 * fresnel
                 * getSunVisibility(playerPos, waveN, max(NdotL, 0.05), dither)
                 * smoothstep(0.12, 0.42, lmcoord.y);
#endif

        color = mix(body, reflection, fresnel) + specular;

        // From underneath, the surface should mostly be a window, not a mirror.
        alpha = (isEyeInWater == 1) ? mix(0.10, 0.75, fresnel)
                                    : mix(WATER_OPACITY, 0.96, fresnel);
    } else {
        // Stained glass, ice, slime: ordinary shading, vanilla alpha.
        color = shadeSurface(albedo.rgb, N, lmcoord, playerPos, dither);
        alpha = albedo.a;
    }

    gl_FragData[0] = vec4(color, alpha);
    gl_FragData[1] = vec4(isWater, 0.0, 0.0, 1.0);
}
