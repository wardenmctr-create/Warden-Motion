// texturize
uniform sampler2D s_dokuDosy; uniform float p_dokuDosyOn; uniform float p_doku, p_olcek, p_kabartma, p_aci, p_dokuGucu, p_tersDoku;
float tx(vec2 p) {
  if (p_dokuDosyOn > 0.5 || p_doku > 3.5) return luma(unpre(texture(s_dokuDosy, fract(p / 120.0))));
  if (p_doku < 0.5) { vec2 f = fract(p / 4.0); return 0.5 + 0.25 * (sin(p.x * 1.6) * 0.5 + sin(p.y * 1.6) * 0.5) * step(0.5, f.x + f.y * 0.0) + vnoise(p * 0.6) * 0.2; }
  if (p_doku < 1.5) return 0.5 + (fbm(p / 8.0, 3.0)) * 0.35 + (hash1(floor(p)) - 0.5) * 0.08;
  if (p_doku < 2.5) { vec2 b = p / vec2(40.0, 18.0); b.x += step(1.0, mod(floor(b.y), 2.0)) * 0.5; vec2 f = fract(b); float m = step(0.06, f.x) * step(0.1, f.y); return 0.35 + 0.4 * m + vnoise(p * 0.3) * 0.15; }
  return 0.5 + 0.3 * sin(p.x * 0.15 + fbm(p / vec2(80.0, 10.0), 2.0) * 6.0);
}
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 p = toUnit(here()) / max(p_olcek / 100.0, 0.01); float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)) * max(p_kabartma, 0.3);
  float h = tx(p), h2 = tx(p + d); if (p_tersDoku > 0.5) { h = 1.0 - h; h2 = 1.0 - h2; }
  float sh = (h2 - h) * p_kabartma * 0.5 + (h - 0.5) * 0.4;
  o = pre(clamp(unpre(s) * (1.0 + sh * p_dokuGucu / 100.0 * 1.6), 0.0, 1.0), s.a);
}
