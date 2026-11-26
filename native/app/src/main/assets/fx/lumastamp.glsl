// lumastamp
uniform float p_siyahNokt, p_beyazNokt, p_gama, p_mevcutAlfaCarp, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float l = luma(unpre(s)); l = clamp((l - p_siyahNokt / 100.0) / max((p_beyazNokt - p_siyahNokt) / 100.0, 0.01), 0.0, 1.0); l = pow(l, 1.0 / max(p_gama, 0.01)); if (p_ters > 0.5) l = 1.0 - l;
  float a = p_mevcutAlfaCarp > 0.5 ? l * s.a : l; o = pre(unpre(s), a); }
