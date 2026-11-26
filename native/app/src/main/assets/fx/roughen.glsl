// roughen
uniform float p_kenarMikt, p_dokuOlce, p_ayrinti, p_evrim, p_tohum, p_kenarYumu, p_kenarBicim, p_cokgen, p_koseYumu, p_kenarSert, p_dinamik, p_yenilenme, p_degisim, p_hafiza, p_anaSiluet;
void main() {
  vec2 q = toUnit(here()); float sd0 = seedf(p_tohum); float sd = sd0;
  if (p_dinamik > 0.5) { float tick = floor(u_t * 30.0 / max(p_yenilenme, 1.0)); sd = mix(sd0, sd0 + tick * 7.31, (1.0 - p_hafiza / 100.0) + p_degisim / 100.0 * 0.5); }
  float sc = max(p_dokuOlce, 1.0); float st = p_kenarBicim;
  if (st > 0.5 && st < 1.5) sc *= 3.0; if (st > 2.5 && st < 3.5) sc *= 2.0; if (st > 4.5) sc *= 4.0;
  vec2 n = q / sc + sd; float oc = st > 3.5 && st < 4.5 ? p_ayrinti : (st < 0.5 ? p_ayrinti + 1.0 : max(p_ayrinti - 1.0, 1.0));
  vec2 d = vec2(fbm(n + vec2(p_evrim * 0.05, 0.0), oc - 1.0), fbm(n + vec2(3.7, -p_evrim * 0.05), oc - 1.0));
  if (st > 2.5 && st < 3.5) d = vec2(sin(q.y / sc * TAU * 2.0 + sd), sin(q.x / sc * TAU * 2.0 + sd)) * 0.6;
  vec2 pd = q + d * p_kenarMikt;
  float poly = st > 1.5 && st < 2.5 ? max(p_cokgen / 100.0, 0.5) : p_cokgen / 100.0 * 0.5;
  if (poly > 0.01) { float cell = max(p_kenarMikt * 1.5, 2.0); pd = mix(pd, (floor(pd / cell) + 0.5) * cell, poly); }
  vec4 s = texU(q); vec4 w = texU(pd);
  float soft = max(p_kenarYumu, 0.3) * 0.1 + (1.0 - p_kenarSert / 100.0) * 0.25 + p_koseYumu / 100.0 * 0.1;
  float a = smoothstep(0.5 - soft, 0.5 + soft, w.a);
  if (p_anaSiluet > 0.5) a = mix(a, s.a, 0.0);
  o = pre(s.a > 0.01 ? unpre(s) : unpre(w), a);
}
