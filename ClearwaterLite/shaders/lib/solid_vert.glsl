#include "/lib/common.glsl"
#include "/lib/sky.glsl"

#ifdef PROGRAM_TERRAIN
#include "/lib/waving.glsl"
attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;
#endif

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vcolor;
varying vec3 wnormal;
varying vec3 playerPos;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = remapLightmap((gl_TextureMatrix[1] * gl_MultiTexCoord1).xy);
    vcolor   = gl_Color;
    wnormal  = normalize(mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal));

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    playerPos = (gbufferModelViewInverse * viewPos).xyz;

#ifdef PROGRAM_TERRAIN
    // Vertices above the texture midpoint are the top of the block, which is
    // what lets grass bend from its base instead of sliding as a whole.
    float isTop = float(gl_MultiTexCoord0.y < mc_midTexCoord.y);
    playerPos += getWaveOffset(playerPos + cameraPosition, mc_Entity.x, isTop, lmcoord.y);
    gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(playerPos, 1.0));
#else
    gl_Position = gl_ProjectionMatrix * viewPos;
#endif
}
