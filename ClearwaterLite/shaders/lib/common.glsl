#ifndef LIB_COMMON
#define LIB_COMMON

#include "/lib/settings.glsl"

/*
    Every uniform that more than one program needs lives here. Declaring an
    unused uniform costs nothing, and keeping them in one place means no
    program can accidentally declare the same one twice.
*/

uniform mat4  gbufferModelView;
uniform mat4  gbufferModelViewInverse;
uniform mat4  gbufferProjection;
uniform mat4  gbufferProjectionInverse;

uniform vec3  cameraPosition;
uniform vec3  sunPosition;            // view space
uniform vec3  moonPosition;
uniform vec3  shadowLightPosition;

uniform float frameTimeCounter;
uniform float rainStrength;
uniform float wetness;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float blindness;
uniform float nightVision;

uniform int   isEyeInWater;
uniform int   heldBlockLightValue;
uniform int   heldBlockLightValue2;

#define PI 3.14159265
#define TAU 6.28318531

float saturate(float x) { return clamp(x, 0.0, 1.0); }
vec3  saturate(vec3 x)  { return clamp(x, vec3(0.0), vec3(1.0)); }

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

// Cheap gamma 2.0 <-> linear. Two multiplies instead of pow(x, 2.2);
// on a seven year old card that difference is worth the tiny hue shift.
vec3 toLinear(vec3 c)  { return c * c; }
vec3 toGamma(vec3 c)   { return sqrt(max(c, vec3(0.0))); }

// Ordered dither, used to rotate the shadow filter kernel per pixel.
// Stable between frames, so it never sparkles the way white noise does.
float bayer2(vec2 a) { a = floor(a); return fract(dot(a, vec2(0.5, a.y * 0.75))); }
#define bayer4(a)  (bayer2(0.5 * (a)) * 0.25 + bayer2(a))
#define bayer8(a)  (bayer4(0.5 * (a)) * 0.25 + bayer4(a))

// Vanilla lightmap coords arrive padded by half a texel on each side.
vec2 remapLightmap(vec2 lm) {
    return clamp((lm - 0.03125) * 1.06667, 0.0, 1.0);
}

vec3 viewSpacePos(vec2 uv, float depth, mat4 projInverse) {
    vec4 p = projInverse * vec4(vec3(uv, depth) * 2.0 - 1.0, 1.0);
    return p.xyz / p.w;
}

float linearizeDepth(float depth, float near, float far) {
    return (2.0 * near * far) / (far + near - (depth * 2.0 - 1.0) * (far - near));
}

#endif
