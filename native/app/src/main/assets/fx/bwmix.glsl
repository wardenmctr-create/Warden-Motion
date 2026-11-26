// bwmix
uniform float p_kirmizi, p_sari, p_yesil, p_camgobeg, p_mavi, p_mor, p_renkTonuEkle; uniform vec3 c_ton;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsv(c); float hx = h.x * 6.0;
  float w[6] = float[6](p_kirmizi, p_sari, p_yesil, p_camgobeg, p_mavi, p_mor);
  int i0 = int(floor(hx)) % 6; int i1 = (i0 + 1) % 6; float wv = mix(w[i0], w[i1], fract(hx)) / 100.0;
  float g = luma(c) + (wv - 0.4) * h.y * h.z * 0.8;
  vec3 r = vec3(clamp(g, 0.0, 1.0)); if (p_renkTonuEkle > 0.5) r = softLightB(r, c_ton);
  o = pre(r, s.a);
}
