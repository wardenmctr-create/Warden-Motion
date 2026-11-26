// flagwave
uniform float p_sabitKena, p_sabitSeriGeni, p_dalgaYuks, p_dalgaBoyu, p_ruzgarHizi, p_ruzgarAcis, p_faz, p_ikinciDalg, p_duzensiz, p_tohum, p_p3bGolg, p_isikAcis, p_golgeGucu, p_kenarlarKoru, p_kusursuzDong, p_donguSure;
uniform vec2 p_ozelSabiCizg, p_ozelSabiCizg2;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 b = boxUV(here());
  // serbest yön ve sabit kenardan normalize uzaklık u
  vec2 fdir; float u;
  if (p_sabitKena < 0.5) { fdir = vec2(1, 0); u = b.x; } else if (p_sabitKena < 1.5) { fdir = vec2(-1, 0); u = 1.0 - b.x; } else if (p_sabitKena < 2.5) { fdir = vec2(0, 1); u = b.y; } else if (p_sabitKena < 3.5) { fdir = vec2(0, -1); u = 1.0 - b.y; }
  else { vec2 a = p_ozelSabiCizg, c = p_ozelSabiCizg2; vec2 d = normalize(c - a + 1e-5); fdir = vec2(d.y, -d.x); if (dot(-a, fdir) < 0.0) fdir = -fdir; u = clamp(dot(q - a, fdir) / max(abs(dot(B, abs(fdir))), 1.0), 0.0, 1.0); }
  float s = p_sabitSeriGeni / 100.0; float w = smoothstep(s, 1.0, u) * smoothstep(s, min(s + 0.35, 1.0), u);
  float dist = u * abs(dot(B, abs(fdir))); float f = p_ruzgarHizi; if (p_kusursuzDong > 0.5) f = max(1.0, floor(f * p_donguSure + 0.5)) / max(p_donguSure, 0.01);
  float ph = TAU * (dist / max(p_dalgaBoyu, 1.0) - f * u_t) + radians(p_faz) + radians(p_ruzgarAcis) * 0.0;
  float irr = (vnoise(vec2(dist / max(p_dalgaBoyu, 1.0) * 1.7 - f * u_t * 0.8, seedf(p_tohum))) - 0.5) * 2.0 * p_duzensiz / 100.0;
  float h = sin(ph) + p_ikinciDalg / 100.0 * sin(ph * 2.13 + 1.3) + irr; float disp = p_dalgaYuks * w * h;
  vec2 perp = vec2(-fdir.y, fdir.x); vec2 sq = q - perp * disp - fdir * disp * 0.15 * cos(ph);
  vec4 c = texU(sq); if (p_kenarlarKoru < 0.5) c = texEdge(fromUnit(sq), 3.0) * step(0.001, texU(sq).a + 0.001);
  if (p_p3bGolg > 0.5 && c.a > 0.0) { float slope = cos(ph) * w; float la = radians(p_isikAcis); float lit = slope * cos(la) * p_golgeGucu / 100.0 * 1.6; c.rgb = clamp(c.rgb * (1.0 + lit), 0.0, c.a); }
  o = c;
}
