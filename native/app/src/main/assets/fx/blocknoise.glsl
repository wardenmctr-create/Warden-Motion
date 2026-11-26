// blocknoise
uniform float p_blokBoyu, p_renkCesi, p_yogunluk, p_yenilenm, p_tohum, p_tekRenk, p_guc, p_dondur, p_ucDeger, p_parlakUst, p_karistir, p_tohumAK; uniform vec2 p_esnet, p_kaydir;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 bs = max(p_blokBoyu, 1.0) * max(p_esnet, vec2(1.0)) / 100.0; vec2 id = floor((toUnit(here()) - p_kaydir) / bs);
  float tk = p_dondur > 0.5 ? 0.0 : floor(u_t * p_yenilenm); float sd = seedf(p_tohumAK > 0.5 ? floor(p_tohum) : p_tohum);
  float on = step(hash1(id + tk * 7.1 + sd), p_yogunluk / 100.0);
  float v = hash1(id + tk + sd + 3.0); if (p_ucDeger > 0.5) v = step(0.5, v);
  vec3 c = p_tekRenk > 0.5 ? vec3(v) : mix(vec3(hash1(id + tk + 1.0)), hsv2rgb(vec3(hash1(id + tk + 5.0 + sd), 0.9, 0.95)), p_renkCesi / 100.0);
  if (p_ucDeger > 0.5 && p_tekRenk < 0.5) c = step(0.5, c); c = min(c * p_parlakUst / 100.0, vec3(2.0));
  vec3 b = unpre(s); vec3 r = p_karistir < 0.5 ? c : p_karistir < 1.5 ? b * c : p_karistir < 2.5 ? screenB(b, c) : b + c;
  float k = on * p_guc / 100.0; o = pre(clamp(mix(b, r, k), 0.0, 1.0), p_karistir < 0.5 ? max(s.a, k) * step(0.001, s.a + (p_karistir < 0.5 ? 1.0 : 0.0)) * s.a + 0.0 : s.a);
  if (p_karistir < 0.5) o = overPre(vec4(c, 1.0) * k * s.a, s * (1.0 - k));
}
