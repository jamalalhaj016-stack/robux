#ifndef LIB_BLUR
#define LIB_BLUR

/*
    13 tap gaussian collapsed to 7 bilinear fetches. Two of these, one per
    axis, is the whole bloom chain - no mip pyramid, no extra targets.
*/
vec3 blurAxis(sampler2D tex, vec2 uv, vec2 dir) {
    vec2 o1 = dir * 1.411764705882353;
    vec2 o2 = dir * 3.294117647058823;
    vec2 o3 = dir * 5.176470588235294;

    vec3 c  = texture2D(tex, uv).rgb * 0.196482550151140;
    c += (texture2D(tex, uv + o1).rgb + texture2D(tex, uv - o1).rgb) * 0.296906964672834;
    c += (texture2D(tex, uv + o2).rgb + texture2D(tex, uv - o2).rgb) * 0.094470397850447;
    c += (texture2D(tex, uv + o3).rgb + texture2D(tex, uv - o3).rgb) * 0.010381362401148;
    return c;
}

#endif
