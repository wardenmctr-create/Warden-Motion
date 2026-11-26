// lumakey
uniform float p_esik, p_yumusakl, p_yontem, p_alfaylaCarp, p_matiGost;
void main() { vec4 s = texture(u_tex, v_uv); float l = luma(unpre(s)); float w = max(p_yumusakl / 200.0, 0.002);
  float a = smoothstep(p_esik / 100.0 - w, p_esik / 100.0 + w, l); if (p_yontem > 0.5) a = 1.0 - a; if (p_alfaylaCarp > 0.5) a *= s.a;
  if (p_matiGost > 0.5) { o = vec4(vec3(a), 1.0); return; } o = pre(unpre(s), a); }
