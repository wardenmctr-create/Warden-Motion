// broadcast
uniform float p_yayinStan, p_duzeltme, p_sinirDisiGost, p_yasalAral;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float lo = p_yasalAral > 0.5 ? 16.0 / 255.0 : 0.0, hi = p_yasalAral > 0.5 ? 235.0 / 255.0 : 1.0;
  float l = luma(c); float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); float maxS = p_yayinStan < 0.5 ? 0.85 : 0.75;
  bool bad = l > hi || l < lo || sat > maxS;
  if (p_sinirDisiGost > 0.5 && bad) { o = pre(vec3(1.0, 0.0, 1.0), s.a); return; }
  if (p_duzeltme < 0.5) c *= min(1.0, hi / max(l, 1e-3)); else if (p_duzeltme < 1.5) c = satAdj(c, min(1.0, maxS / max(sat, 1e-3))); else c = clamp(c, lo, hi);
  c = mix(vec3(lo), vec3(hi), c);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
