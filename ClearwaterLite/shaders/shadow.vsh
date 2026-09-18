#version 120
#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/waving.glsl"
#include "/lib/water.glsl"
#include "/lib/shadowdistort.glsl"

uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

varying vec2 texcoord;
varying vec4 vcolor;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vcolor   = gl_Color;

    vec4 pos = gl_ModelViewMatrix * gl_Vertex;
    vec3 playerPos = (shadowModelViewInverse * pos).xyz;
    vec3 worldPos = playerPos + cameraPosition;

    // Casters have to wave exactly like the geometry in gbuffers_terrain does,
    // otherwise the shadow slides off its own blade of grass.
    float skyLight = remapLightmap((gl_TextureMatrix[1] * gl_MultiTexCoord1).xy).y;
    float isTop = float(gl_MultiTexCoord0.y < mc_midTexCoord.y);
    playerPos += getWaveOffset(worldPos, mc_Entity.x, isTop, skyLight);

    if (mc_Entity.x == 10.0) {
        vec3 wn = normalize(mat3(shadowModelViewInverse) * (gl_NormalMatrix * gl_Normal));
        if (wn.y > 0.5) playerPos.y += waterDisplacement(worldPos.xz);
    }

    gl_Position = gl_ProjectionMatrix * (shadowModelView * vec4(playerPos, 1.0));
    gl_Position.xyz = distortShadowClip(gl_Position.xyz);
}
