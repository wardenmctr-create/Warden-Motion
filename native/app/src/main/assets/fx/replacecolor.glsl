// replacecolor
uniform vec3 c_kaynakRenk, c_hedefRenk; uniform float p_tolerans, p_kenarGeci, p_parlakliKoru, p_eslesmeyGost;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsv(c), k = rgb2hsv(c_kaynakRenk);
  float d = length(vec3(min(abs(h.x - k.x), 1.0 - abs(h.x - k.x)) * 2.0, (h.y - k.y) * 0.5, (h.z - k.z) * 0.35));
  float tol = p_tolerans / 100.0 * 0.6; float m = 1.0 - smoothstep(tol, tol + p_kenarGeci / 100.0 * 0.4 + 0.001, d);
  vec3 t = c_hedefRenk; if (p_parlakliKoru > 0.5) { vec3 th = rgb2hsv(t); t = hsv2rgb(vec3(th.x, th.y * min(1.0, h.y / max(k.y, 0.05)), clamp(h.z * th.z / max(k.z, 0.05), 0.0, 1.0))); }
  if (p_eslesmeyGost > 0.5) { o = pre(vec3(m), s.a); return; }
  o = pre(mix(c, t, m), s.a);
}
