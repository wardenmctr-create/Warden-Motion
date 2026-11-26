// timediff
INCLUDE(_hist)
uniform float p_zamanFark, p_kazanc, p_esik, p_yontem, p_tekRenk, p_alfayiKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 1.0) { o = s; return; } vec4 h = hist(0.0, v_uv);
  vec3 a = s.rgb - h.rgb; float g = p_kazanc / 100.0 * 3.0; float th = p_esik / 100.0; vec3 m = max(abs(a) - th, 0.0) * g;
  vec3 r = p_yontem < 0.5 ? m : 0.5 + sign(a) * m * 0.5;
  if (p_tekRenk > 0.5) r = vec3(p_yontem < 0.5 ? max(r.r, max(r.g, r.b)) : luma(r));
  float al = p_alfayiKoru > 0.5 ? s.a : max(s.a, h.a); o = vec4(clamp(r, 0.0, 1.0) * al, al); }
