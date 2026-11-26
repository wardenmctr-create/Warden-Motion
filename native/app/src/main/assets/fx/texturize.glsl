// texturize
INCLUDE(_mat)
uniform sampler2D s_ozelDoku; uniform float p_ozelDokuOn;
uniform float p_dokuTuru, p_dokuTohum, p_dokuGucu, p_dokuOlcek, p_dokuAci, p_kaydirX, p_kaydirY, p_tekrar, p_dikisGizle, p_kabartma, p_kabartmaAci, p_kabartmaYogun, p_lif, p_buruskluk,
  p_renkleBirles, p_dokuOpak, p_tersDoku, p_sadeceAydin, p_sadeceGolge, p_dokuKontrast, p_dokuParlak, p_puruzluluk, p_yuzeyParlak, p_alfaKoru, p_nesneSabit, p_esnet, p_dogalRenk,
  p_olukGeni, p_olukDerin, p_olukYon, p_kirisBuyu, p_kirisYogun, p_damarGeni; uniform vec2 p_dokuKaydir; uniform vec3 c_dokuRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if ((s.a <= 0.0 && p_alfaKoru > 0.5) || p_dokuGucu <= 0.0) { o = s; return; }
  // eski 14 + yeni 10 malzeme
  const int MAP[24] = int[24](18, 1, 3, 4, 6, 5, 7, 19, 20, 12, 10, 11, 21, 17, 1, 2, 8, 9, 11, 20, 14, 13, 10, 20);
  int i0 = int(clamp(p_dokuTuru, 0.0, 23.0)); int id = MAP[i0];
  vec2 base = p_nesneSabit > 0.5 ? (p_esnet > 0.5 ? (boxUV(here()) - 0.5) * 600.0 : toUnit(here())) : here() / max(u_s, 0.01);
  vec2 p = rot2(-p_dokuAci) * (base - vec2(p_kaydirX, p_kaydirY) - p_dokuKaydir) / max(p_dokuOlcek / 100.0, 0.05); float sd = seedf(p_dokuTohum);
  vec4 sp = id == 4 ? vec4(p_olukGeni / 40.0, p_olukDerin / 100.0, p_olukYon / 180.0, 0.0) : id == 7 ? vec4(p_kirisBuyu / 200.0, 0.6, p_kirisYogun / 100.0, 0.0) : id == 12 ? vec4(p_damarGeni / 40.0, 0.0, 0.0, 0.0) : vec4(0.3, 0.6, 0.0, 0.5);
  float fib = p_lif / 100.0, cr = p_buruskluk / 100.0;
  vec3 mc; float h;
  if (id == 17) { vec2 tuv = p / 200.0; tuv = p_tekrar > 0.5 ? fract(tuv) : clamp(tuv + 0.5, 0.0, 1.0); vec4 t = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, tuv) : vec4(0.8);
    if (p_tekrar > 0.5 && p_dikisGizle > 0.0) { vec2 f = fract(p / 200.0); float e = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)); vec4 t2 = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, fract(p / 200.0 + 0.5)) : t; t = mix(t2, t, smoothstep(0.0, p_dikisGizle / 100.0 * 0.25 + 1e-3, e)); }
    mc = unpre(t); h = luma(mc); }
  else { vec4 m = matSample(id, p, sd, sp, fib, cr); mc = m.rgb; h = m.a;
    if (i0 == 22) { mc = vec3(0.45, 0.28, 0.18) * (0.85 + 0.3 * fbm(p / 10.0, 3.0)); h = 0.5 + fbm(p / 4.0 + sd, 4.0) * 0.3; }      // deri
    if (i0 == 23) { mc = vec3(0.86, 0.76, 0.55) * (0.9 + hash1(floor(p * 1.5)) * 0.2); h = 0.5 + (hash1(floor(p * 1.5) + sd) - 0.5) * 0.5; } } // kum
  if (p_tersDoku > 0.5) h = 1.0 - h;
  float light = id == 17 ? 1.0 + (h - 0.5) * p_kabartma * 0.1 : matLight(id, p, sd, sp, fib, cr, p_kabartma * (0.3 + p_kabartmaYogun / 100.0 * 2.0) * (0.5 + p_puruzluluk / 100.0), p_kabartmaAci);
  light += pow(max(light - 1.0, 0.0), 2.0) * p_yuzeyParlak / 100.0 * 2.0;
  vec3 c = unpre(s); float l = luma(c);
  float w = p_dokuGucu / 100.0 * p_dokuOpak / 100.0; if (p_sadeceAydin > 0.5) w *= smoothstep(0.3, 0.8, l); if (p_sadeceGolge > 0.5) w *= 1.0 - smoothstep(0.2, 0.7, l);
  vec3 tint = mc / max(matBase(id), vec3(0.05)); tint = (tint - 1.0) * (1.0 + p_dokuKontrast / 100.0) + 1.0 + p_dokuParlak / 100.0 * 0.5;
  vec3 natural = p_dogalRenk > 0.5 ? mc : tint;
  vec3 r = p_renkleBirles > 0.5 ? c * mix(vec3(1.0), tint * light * c_dokuRenk, w) : mix(c, natural * c_dokuRenk * light, w);
  if (p_dogalRenk > 0.5 && p_renkleBirles > 0.5) r = mix(c, mc * light * c_dokuRenk * (0.5 + l), w);
  o = pre(clamp(r, 0.0, 1.0), p_alfaKoru > 0.5 ? s.a : max(s.a, w));
}
