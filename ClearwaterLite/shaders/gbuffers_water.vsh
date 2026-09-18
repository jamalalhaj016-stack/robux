#version 120
#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/waving.glsl"
#include "/lib/water.glsl"

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

varying vec2  texcoord;
varying vec2  lmcoord;
varying vec4  vcolor;
varying vec3  wnormal;
varying vec3  playerPos;
varying float isWater;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = remapLightmap((gl_TextureMatrix[1] * gl_MultiTexCoord1).xy);
    vcolor   = gl_Color;
    wnormal  = normalize(mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal));

    playerPos = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;
    vec3 worldPos = playerPos + cameraPosition;

    isWater = float(mc_Entity.x == 10.0);

    if (isWater > 0.5) {
        // Only the top face moves. Displacing the sides would tear the mesh
        // away from the block next to it.
        if (wnormal.y > 0.5) playerPos.y += waterDisplacement(worldPos.xz);
    } else {
        float isTop = float(gl_MultiTexCoord0.y < mc_midTexCoord.y);
        playerPos += getWaveOffset(worldPos, mc_Entity.x, isTop, lmcoord.y);
    }

    gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(playerPos, 1.0));
}
