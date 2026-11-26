// glitch
uniform float p_blokMikt, p_blokBoyu, p_kayma, p_rgbAyri, p_taramaCizg, p_tekrarla, p_tohum, p_kareTut, p_tur, p_yatayOran, p_dikeyOran, p_siklik, p_sure, p_renkKayip, p_elle, p_tetikGuc, p_parlakSinir;
void main() {
  vec2 px = here(); float tq = p_kareTut > 0.5 ? floor(u_t * max(p_tekrarla, 0.01)) : u_t * p_tekrarla; float sd = seedf(p_tohum);
  // sıklık/süre: bozulma yalnız belirli anlarda; elle tetiklemede güç
  float act = 1.0; if (p_siklik > 0.0) { float per = 1.0 / p_siklik; float k = floor(u_t / per); float st = hash1(vec2(k, sd)) * max(per - p_sure, 0.0); act = step(st, mod(u_t, per)) * step(mod(u_t, per), st + p_sure); }
  if (p_elle > 0.5) act = p_tetikGuc / 100.0;
  float bw = max(p_blokBoyu, 1.0) * u_s; vec2 bs = vec2(bw * 3.0 * p_yatayOran / 100.0, bw * p_dikeyOran / 100.0);
  float by = floor((px.y - u_box.y) / bs.y); float r = hash1(vec2(by, tq + sd)), r2 = hash1(vec2(by * 1.7, tq * 1.3 + sd + 5.0));
  float on = step(r, p_blokMikt / 100.0) * act; float bx = floor((px.x - u_box.x) / bs.x); float on2 = step(hash1(vec2(bx, by + tq * 7.0 + sd)), p_blokMikt / 250.0) * act;
  float sh = (on * (r2 * 2.0 - 1.0) + on2 * (hash1(vec2(bx, by)) - 0.5)) * p_kayma * u_s;
  if (p_tur > 0.5 && p_tur < 1.5) sh = sin(px.y * 0.05 + u_t * 10.0) * p_kayma * u_s * 0.3 * act + sh * 0.3;
  if (p_tur > 2.5 && p_tur < 3.5) sh *= step(0.5, fract(px.y / max(u_s * 3.0, 2.0)));
  float ca = (on + on2 * 0.5) * p_rgbAyri * u_s + p_rgbAyri * u_s * 0.15 * act; vec2 p = px + vec2(sh, 0.0);
  if (p_tur > 1.5 && p_tur < 2.5 && (on + on2) > 0.0) p = floor(p / bs) * bs + bs * 0.5;
  if (p_tur > 3.5 && (on + on2) > 0.0) p += vec2(hash1(vec2(bx, tq)) - 0.5, hash1(vec2(by, tq)) - 0.5) * bs * 2.0;
  vec4 g = texPx(p); vec4 c = vec4(texPx(p + vec2(ca, 0.0)).r, g.g, texPx(p - vec2(ca, 0.0)).b, 0.0); c.a = max(g.a, max(texPx(p + vec2(ca, 0.0)).a, texPx(p - vec2(ca, 0.0)).a));
  if (p_renkKayip > 0.0) { vec2 cp = floor(p / (2.0 + p_renkKayip * 0.2)) * (2.0 + p_renkKayip * 0.2); vec3 lo = unpre(texPx(cp)); vec3 cc = c.a > 0.0 ? c.rgb / c.a : vec3(0.0); cc = mix(cc, vec3(luma(cc)) + (lo - vec3(luma(lo))), p_renkKayip / 100.0); c = pre(cc, c.a); }
  c.rgb *= 1.0 - p_taramaCizg / 100.0 * 0.6 * step(0.5, fract(px.y / max(2.0, u_s * 2.0)));
  if (p_parlakSinir > 0.5) c.rgb = min(c.rgb, vec3(c.a));
  o = c;
}
