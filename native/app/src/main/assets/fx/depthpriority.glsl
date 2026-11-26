// depthpriority
uniform sampler2D s_onArkaDeri, s_ikinciGoru; uniform float p_onArkaDeriOn, p_ikinciGoruOn, p_tolerans, p_gecis;
void main() { vec4 s = texture(u_tex, v_uv); if (p_ikinciGoruOn < 0.5) { o = s; return; } vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec4 o2 = texture(s_ikinciGoru, b);
  float d1 = p_onArkaDeriOn > 0.5 ? luma(unpre(texture(s_onArkaDeri, b))) : luma(unpre(s)); float d2 = luma(unpre(o2)); float w = smoothstep(-p_gecis / 100.0 - p_tolerans / 100.0, p_gecis / 100.0 + 1e-3, d1 - d2);
  o = mix(overPre(s, o2), overPre(o2, s), w); }
