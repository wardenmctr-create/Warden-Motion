// innerglow
uniform vec3 c_renk; uniform float p_yaricap, p_yogunluk, p_yayilma, p_kaynak, p_karistir;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float R = max(p_yaricap * u_s, 1.0); float d = innerDist(here(), R) / R;
  float g = p_kaynak < 0.5 ? 1.0 - smoothstep(p_yayilma / 100.0 * 0.8, 1.0, d) : smoothstep(0.0, 1.0 - p_yayilma / 100.0 * 0.8, d);
  g *= p_yogunluk / 100.0; vec3 c = unpre(s);
  vec3 r = p_karistir < 0.5 ? screenB(c, c_renk * g) : mix(c, c_renk, g);
  o = pre(r, s.a);
}
