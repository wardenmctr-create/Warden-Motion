// temperature
uniform float p_sicaklik, p_renkTonu, p_guc;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 w = kelvin(clamp(p_sicaklik, 1000.0, 40000.0)) / kelvin(6500.0);
  // düşük K = sıcak görüntü: aydınlatmanın tersini uygula (ışık beyaz dengesi gibi)
  vec3 g = c / max(w, vec3(0.05)); g *= luma(c) / max(luma(g), 1e-3);
  g.g *= 1.0 - p_renkTonu / 100.0 * 0.25; g.rb *= 1.0 + p_renkTonu / 100.0 * 0.12;
  o = pre(clamp(mix(c, g, p_guc / 100.0), 0.0, 1.0), s.a);
}
