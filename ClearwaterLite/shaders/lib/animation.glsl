// Entity animation system for mobs and players - OPTIMIZED FOR OLD GPUs

uniform float frameTimeCounter;

// Simple idle bob - only one sin call per vertex
vec3 getSimpleAnimation(vec3 pos, vec4 color, float time) {
    vec3 offset = vec3(0.0);

    // Single sine wave for idle bob - cheap and effective
    float bob = sin(time * 2.0) * 0.025;
    offset.y += bob;

    // Minimal horizontal sway
    offset.x += sin(time * 1.2 + pos.x * 0.05) * 0.01;

    return offset;
}

// Mob-specific animations - lean and mean for old GPUs
vec3 getMobSpecificAnimation(vec3 pos, vec4 color, float time) {
    vec3 offset = vec3(0.0);

    // Single sine call for all mobs - base bob
    float baseBob = sin(time * 2.0) * 0.02;
    offset.y += baseBob;

    // Minimal variation based on color for visual diversity
    if (color.g > 0.5) {
        // Greenish mobs - slightly faster bob
        offset.y += sin(time * 2.5) * 0.008;
    } else if (color.r > 0.5) {
        // Reddish mobs - side sway
        offset.x += sin(time * 1.5 + pos.z * 0.02) * 0.007;
    } else if (color.b > 0.5) {
        // Blue/flying - more vertical
        offset.y += sin(time * 3.0) * 0.012;
    }

    return offset;
}

// Head tilt - very subtle, minimal cost
vec3 getRotationAnimation(vec3 pos, float time) {
    // Only apply to vertices above center (head area)
    if (pos.y > 0.0) {
        float headTilt = sin(time * 1.0) * 0.008;
        return vec3(headTilt * pos.y * 0.08, 0.0, 0.0);
    }
    return vec3(0.0);
}
