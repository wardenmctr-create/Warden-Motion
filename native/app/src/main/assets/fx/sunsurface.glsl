// sunsurface
uniform float p_buyukluk, p_yuzeyAyri, p_yuzeyHare, p_parlakli, p_gunesLeke, p_lekeYogu, p_korona, p_koronaYuks, p_plazmaYayl, p_yayBuyu, p_parlama; uniform vec3 c_anaRenk, c_sicakBolg, c_koyuBolg;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = max(p_buyukluk * 0.5, 2.0); float r = length(q) / R; vec4 acc = vec4(0.0);
  if (r < 1.0) { vec3 n = vec3(q / R, sqrt(1.0 - r * r)); vec2 uv = vec2(atan(n.x, n.z), asin(n.y)) * 4.0; float tt = u_t * p_yuzeyHare / 100.0;
    vec4 v = voronoi(uv * (3.0 + p_yuzeyAyri / 10.0) + tt * 0.3); float gr = smoothstep(0.0, 0.6, v.y - v.x); float f = fbm01(uv * 2.0 + tt * 0.2, 4.0);
    vec3 c = mix(c_koyuBolg, mix(c_anaRenk, c_sicakBolg, f), 0.5 + gr * 0.5); c *= mix(0.55, 1.0, pow(n.z, 0.4)) * p_parlakli / 100.0;
    if (p_gunesLeke > 0.5) { vec4 sv = voronoi(uv * 0.9 + 11.0); float spot = step(hash1(sv.zw), p_lekeYogu / 100.0) * (1.0 - smoothstep(0.08, 0.22, sv.x)); c = mix(c, c_koyuBolg * 0.25, spot); }
    acc = vec4(clamp(c, 0.0, 1.5), 1.0) * smoothstep(1.0, 0.985, r); }
  if (p_korona > 0.5) { float a = atan(q.y, q.x); float rays = 0.6 + 0.4 * fbm01(vec2(a * 4.0, u_t * 0.3), 3.0); float cor = exp(-(r - 1.0) / max(p_koronaYuks / 100.0 * 0.6 * rays, 0.02)) * step(1.0, r); acc = overPre(vec4(c_sicakBolg, 1.0) * cor * 0.7, acc); }
  if (p_plazmaYayl > 0.5) { for (int i = 0; i < 4; i++) { float fi = float(i); float a0 = hash1(vec2(fi, 4.0)) * TAU; vec2 c = vec2(cos(a0), sin(a0)) * R; vec2 l = rot2(-degrees(a0) + 90.0) * (q - c);
      float H = R * p_yayBuyu / 100.0 * (0.6 + 0.4 * sin(u_t * 0.7 + fi)); float arc = abs(length(vec2(l.x, l.y * 1.0) - vec2(0.0, 0.0)) - H * 0.5); float m = (1.0 - smoothstep(0.0, R * 0.03, arc)) * step(0.0, -l.y + 0.0) * step(1.0, r);
      acc = overPre(vec4(c_anaRenk * 1.2, 1.0) * m * 0.8, acc); } }
  acc = overPre(vec4(c_sicakBolg, 1.0) * exp(-max(r - 1.0, 0.0) * 6.0) * step(1.0, r) * p_parlama / 100.0 * 0.5, acc);
  o = overPre(acc, s); }
