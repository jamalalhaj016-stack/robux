#version 120
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex2;

varying vec2 texcoord;

// Narkowicz's ACES fit. One rational function, no LUT, no branches.
vec3 tonemap(vec3 x) {
    const float a = 2.51, b = 0.03, c = 2.43, d = 0.59, e = 0.14;
    return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
}

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;

#ifdef BLOOM
    color += texture2D(colortex2, texcoord).rgb * BLOOM_STRENGTH;
#endif

    color *= EXPOSURE * (1.0 + nightVision * 0.7);
    color = tonemap(color);
    color = toGamma(color);   // matches the gamma 2.0 we applied to albedo

    float l = luma(color);
    color = mix(vec3(l), color, SATURATION);
    color = saturate((color - 0.5) * CONTRAST + 0.5);

#ifdef VIGNETTE
    vec2 v = texcoord - 0.5;
    color *= 1.0 - dot(v, v) * VIGNETTE_STRENGTH;
#endif

    gl_FragColor = vec4(color, 1.0);
}
