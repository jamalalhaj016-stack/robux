#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/animation.glsl"

#ifdef PROGRAM_TERRAIN
#include "/lib/waving.glsl"
attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;
#endif

#ifdef PROGRAM_ENTITIES
attribute vec4 mc_Entity;
#endif

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vcolor;
varying vec3 wnormal;
varying vec3 playerPos;
varying float vBlockId;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = remapLightmap((gl_TextureMatrix[1] * gl_MultiTexCoord1).xy);
    vcolor   = gl_Color;
    wnormal  = normalize(mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal));
#ifdef PROGRAM_TERRAIN
    vBlockId = mc_Entity.x;
#else
    vBlockId = -1.0;
#endif

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    playerPos = (gbufferModelViewInverse * viewPos).xyz;

#ifdef PROGRAM_TERRAIN
    // Vertices above the texture midpoint are the top of the block, which is
    // what lets grass bend from its base instead of sliding as a whole.
    float isTop = float(gl_MultiTexCoord0.y < mc_midTexCoord.y);
    playerPos += getWaveOffset(playerPos + cameraPosition, mc_Entity.x, isTop, lmcoord.y);
    gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(playerPos, 1.0));
#else
#ifdef PROGRAM_ENTITIES
    // Apply mob/player animations
    vec3 animOffset = getMobSpecificAnimation(gl_Vertex.xyz, gl_Color, frameTimeCounter);
    vec3 animRotated = getRotationAnimation(gl_Vertex.xyz, frameTimeCounter);
    vec3 animatedPos = gl_Vertex.xyz + animOffset + (animRotated - gl_Vertex.xyz) * 0.3;
    vec4 animViewPos = gl_ModelViewMatrix * vec4(animatedPos, 1.0);
    gl_Position = gl_ProjectionMatrix * animViewPos;
#else
    gl_Position = gl_ProjectionMatrix * viewPos;
#endif
#endif
}
