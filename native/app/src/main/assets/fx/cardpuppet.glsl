// cardpuppet
INCLUDE(_mat)
uniform sampler2D s_ozelDoku, s_altlikOzel; uniform float p_ozelDokuOn, p_altlikOzelOn; uniform float u_rot;
uniform float p_orijKoru, p_dokuTuru, p_dokuGucu, p_dokuOlcek, p_dokuAci, p_dokuOpak, p_dokuKontrast, p_dokuParlak, p_kabarti, p_lif, p_renkleBirles,
  p_altlikAcik, p_kalinlik, p_ofsX, p_ofsY, p_altlikDoku, p_altlikDokuGuc, p_altlikKabarti, p_disaBuyut, p_kenarStili, p_kusursuz, p_takipSadakat, p_kenarSert, p_koseYumu,
  p_kenarDavr, p_yenilenme, p_kenarDegis, p_kenarKarars, p_bicimHafiza, p_kenarTohum, p_tohumCanl, p_golgeAcik, p_golgeAci, p_golgeUzak, p_golgeYumu, p_golgeOpak;
uniform vec3 c_altlikRenk, c_golgeRenk;
float edgeSeed() { float base = seedf(p_kenarTohum); if (p_kenarDavr < 0.5 || p_tohumCanl < 0.5) return base; float tick = floor(u_t * 30.0 / max(p_yenilenme, 1.0)); return base + tick * 7.13 * (1.0 - p_bicimHafiza / 100.0 * 0.85); }
float backMask(vec2 px, float Rpx) {
  vec2 q = toUnit(px); float R = max(Rpx / u_s, 1.0); float imp = 1.0 - p_kusursuz / 100.0; float st = p_kenarStili;
  float f = st < 2.5 ? 1.0 / (R * 4.0) : st < 3.5 ? 1.0 / (R * 3.0) : st < 4.5 ? 1.0 / max(R * 0.6, 1.5) : 1.0 / (R * 6.0);
  float amp = R * imp * (st < 0.5 ? 0.0 : st < 2.5 ? 0.25 : st < 3.5 ? 0.6 : st < 4.5 ? 0.7 : 0.8) * mix(1.3, 0.7, p_takipSadakat / 100.0);
  float sd0 = seedf(p_kenarTohum), sd1 = edgeSeed();
  vec2 n = mix(vec2(pnoise(q * f + sd0), pnoise(q * f + sd0 + 17.3)), vec2(pnoise(q * f + sd1), pnoise(q * f + sd1 + 17.3)), p_kenarDavr > 0.5 ? p_kenarDegis / 100.0 * 2.0 : 0.0);
  n += (hash2(floor(q / max(R * 0.6, 1.0)) + floor(u_t * 30.0 / max(p_yenilenme, 1.0))) - 0.5) * p_kenarKarars / 100.0 * 0.6 * step(0.5, p_kenarDavr);
  vec2 pd = px + n * amp * u_s;
  if (st > 1.5 && st < 3.5) { float cell = max(Rpx * 1.5, 3.0); pd = mix(pd, (floor(pd / cell) + 0.5) * cell, st < 2.5 ? 0.35 : 0.15); }
  float m = smoothstep(0.08, 0.55, texPx(pd).a);
  for (int k = 1; k <= 3; k++) { float r = Rpx * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.37; m = max(m, smoothstep(0.08, 0.55, texPx(pd + vec2(cos(a), sin(a)) * r).a)); } }
  float soft = mix(0.5, 0.02, p_kenarSert / 100.0) + p_koseYumu / 100.0 * 0.2 + (st > 0.5 && st < 1.5 ? 0.25 : 0.0);
  return smoothstep(0.5 - soft, 0.5 + soft, m);
}
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here());
  // üst doku
  const int TOP[7] = int[7](3, 4, 6, 5, 7, 1, 17); int id = TOP[int(clamp(p_dokuTuru, 0.0, 6.0))];
  vec2 tp = rot2(-p_dokuAci) * q / max(p_dokuOlcek / 100.0, 0.05); vec4 sp = vec4(0.3, 0.6, 0.0, 0.0); float fib = p_lif / 100.0;
  vec4 obj = s;
  if (s.a > 0.0) {
    vec3 mc; float lit;
    if (id == 17) { vec4 t = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, fract(tp / 200.0)) : vec4(0.8); mc = unpre(t); lit = 1.0 + (luma(mc) - 0.5) * p_kabarti * 0.08; }
    else { mc = matSample(id, tp, 2.0, sp, fib, 0.0).rgb; lit = matLight(id, tp, 2.0, sp, fib, 0.0, p_kabarti * 0.8, 135.0); }
    vec3 tex = (mc / max(matBase(id), vec3(0.05)) - 1.0) * (1.0 + p_dokuKontrast / 100.0) + 1.0 + p_dokuParlak / 100.0 * 0.5;
    vec3 c = unpre(s); float w = p_dokuGucu / 100.0 * (p_dokuOpak / 100.0) * 1.4;
    vec3 r = p_renkleBirles > 0.5 ? c * mix(vec3(1.0), tex * lit, clamp(w, 0.0, 1.0)) : mix(c, mc * lit, clamp(w, 0.0, 1.0));
    obj = pre(clamp(mix(r, c, p_orijKoru / 100.0), 0.0, 1.0), s.a);
  }
  if (p_altlikAcik < 0.5) { o = obj; return; }
  vec2 ofs = vec2(p_ofsX, p_ofsY); vec2 bp = here() - ofs * u_s; float m = backMask(bp, p_kalinlik * u_s); if (m <= 0.001) { o = obj; return; }
  const int BK[7] = int[7](3, 4, 6, 5, 7, 0, 17); int bid = BK[int(clamp(p_altlikDoku, 0.0, 6.0))]; vec2 bq = toUnit(bp) / max(p_dokuOlcek / 100.0, 0.05);
  vec3 bc; float bl = 1.0;
  if (bid == 0) bc = c_altlikRenk; else if (bid == 17) { vec4 t = p_altlikOzelOn > 0.5 ? texture(s_altlikOzel, fract(bq / 200.0)) : vec4(0.8); bc = unpre(t); }
  else { vec3 nat = matSample(bid, bq, 5.0, sp, fib, 0.0).rgb; bc = mix(c_altlikRenk, c_altlikRenk * (nat / max(matBase(bid), vec3(0.05))), p_altlikDokuGuc / 100.0); bl = matLight(bid, bq, 5.0, sp, fib, 0.0, p_altlikKabarti * 0.8, 135.0); }
  vec3 col = bc * bl;
  if (p_golgeAcik > 0.5) { float a = radians(p_golgeAci); vec2 so = vec2(cos(a), sin(a)) * p_golgeUzak * u_s; float sh = 0.0; float rr = max(p_golgeYumu * u_s, 0.5);
    for (int i = 0; i < 12; i++) { float an = float(i) * TAU / 12.0; sh += texPx(here() - so + vec2(cos(an), sin(an)) * rr * (0.4 + 0.6 * fract(float(i) * 0.618))).a; } sh = sh / 12.0 * p_golgeOpak / 100.0;
    col = mix(col, col * c_golgeRenk * 1.4, sh); }
  o = overPre(obj, pre(clamp(col, 0.0, 1.0), m));
}
