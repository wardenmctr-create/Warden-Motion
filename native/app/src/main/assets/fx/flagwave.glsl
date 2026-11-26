// flagwave
uniform sampler2D s_arkaGorsel; uniform float p_arkaGorselOn;
uniform float p_sabitKena, p_sabitSeriGeni, p_dalgaYuks, p_dalgaBoyu, p_ruzgarHizi, p_ruzgarAcis, p_faz, p_ikinciDalg, p_duzensiz, p_tohum, p_p3bGolg, p_isikAcis, p_golgeGucu, p_kenarlarKoru, p_kusursuzDong, p_donguSure,
  p_sertlik, p_agirlik, p_sarkma, p_degisken, p_degisGuc, p_degisSik, p_ucTitre, p_kumasParlak, p_kumasDoku, p_arkaGoster, p_arkaYuz;
uniform vec2 p_ozelSabiCizg, p_ozelSabiCizg2; uniform vec3 c_arkaRenk;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 b = boxUV(here()); vec2 fdir; float u;
  if (p_sabitKena < 0.5) { fdir = vec2(1, 0); u = b.x; } else if (p_sabitKena < 1.5) { fdir = vec2(-1, 0); u = 1.0 - b.x; } else if (p_sabitKena < 2.5) { fdir = vec2(0, 1); u = b.y; } else if (p_sabitKena < 3.5) { fdir = vec2(0, -1); u = 1.0 - b.y; }
  else { vec2 a = p_ozelSabiCizg, c = p_ozelSabiCizg2; vec2 d = normalize(c - a + 1e-5); fdir = vec2(d.y, -d.x); if (dot(-a, fdir) < 0.0) fdir = -fdir; u = clamp(dot(q - a, fdir) / max(abs(dot(B, abs(fdir))), 1.0), 0.0, 1.0); }
  float s = p_sabitSeriGeni / 100.0; float w = smoothstep(s, 1.0, u) * smoothstep(s, min(s + 0.35, 1.0), u);
  w = pow(w, mix(0.6, 1.6, p_sertlik / 100.0));
  float dist = u * abs(dot(B, abs(fdir))); float f = p_ruzgarHizi; if (p_kusursuzDong > 0.5) f = max(1.0, floor(f * p_donguSure + 0.5)) / max(p_donguSure, 0.01);
  float amp = p_dalgaYuks; if (p_degisken > 0.5) amp *= 1.0 + (vnoise(vec2(u_t * p_degisSik, seedf(p_tohum) + 3.0)) - 0.5) * 2.0 * p_degisGuc / 100.0;
  float ph = TAU * (dist / max(p_dalgaBoyu, 1.0) - f * u_t) + radians(p_faz);
  float irr = (vnoise(vec2(dist / max(p_dalgaBoyu, 1.0) * 1.7 - f * u_t * 0.8, seedf(p_tohum))) - 0.5) * 2.0 * p_duzensiz / 100.0;
  float tip = smoothstep(0.75, 1.0, u) * sin(ph * 3.7 + u_t * 9.0) * p_ucTitre / 100.0 * 0.5;
  float h = sin(ph) + p_ikinciDalg / 100.0 * sin(ph * 2.13 + 1.3) + irr + tip; float disp = amp * w * h;
  vec2 perp = vec2(-fdir.y, fdir.x);
  // ağırlık: dalga aşağı doğru sarkar (serbest kenara doğru artan)
  vec2 sag = vec2(0.0, (p_sarkma + p_agirlik * 0.3) * w * u);
  vec2 sq = q - perp * disp * (1.0 - p_agirlik / 100.0 * 0.4) - fdir * disp * 0.15 * cos(ph) - sag;
  vec4 c = texU(sq); if (p_kenarlarKoru < 0.5) c = texEdge(fromUnit(sq), 3.0) * step(0.001, texU(sq).a + 0.001);
  // arka yüz: dalganın eğimi tersine döndüğü bölgeler
  float slope = cos(ph) * w * amp / max(p_dalgaBoyu, 1.0) * TAU;
  if (p_arkaGoster > 0.5 && slope < -0.9 && c.a > 0.0) { vec3 back = p_arkaYuz < 0.5 ? unpre(texU(sq * vec2(-1.0, 1.0))) : p_arkaYuz < 1.5 && p_arkaGorselOn > 0.5 ? unpre(texture(s_arkaGorsel, clamp(boxUV(fromUnit(sq)), 0.0, 1.0))) : c_arkaRenk; c = pre(back * 0.8, c.a); }
  if (p_p3bGolg > 0.5 && c.a > 0.0) { float la = radians(p_isikAcis); float lit = cos(ph) * w * cos(la) * p_golgeGucu / 100.0 * 1.6; c.rgb = clamp(c.rgb * (1.0 + lit), 0.0, c.a);
    c.rgb += vec3(pow(max(cos(ph) * w, 0.0), 6.0) * p_kumasParlak / 100.0 * 0.5) * c.a; }
  if (p_kumasDoku > 0.0 && c.a > 0.0) { vec2 fq = sq * 0.8; float wv = mix(sin(fq.x * PI), sin(fq.y * PI), step(0.5, mod(floor(fq.x) + floor(fq.y), 2.0))); c.rgb *= 1.0 - (0.5 - 0.5 * wv) * p_kumasDoku / 100.0 * 0.3; }
  o = c;
}
