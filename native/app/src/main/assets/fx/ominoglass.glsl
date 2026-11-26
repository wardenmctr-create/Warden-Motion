// ominoglass
uniform sampler2D s_dokuKatm; uniform float p_dokuKatmOn;
uniform float p_kirilma, p_prizmaAyri, p_dokuOlce, p_camKali, p_kenarYumu, p_tersHari, p_yukKayn, p_pah, p_puruz, p_puruzOlcek, p_puruzEvrim, p_ornek, p_renkGuc,
  p_isikTur, p_isikYuk, p_isikGuc, p_ortam, p_yParlak, p_keskin; uniform vec2 p_isikKonum; uniform vec3 c_camRenk, c_isikRenk;
float hgt(vec2 q) {
  if (p_yukKayn > 0.5 && p_yukKayn < 1.5) return luma(unpre(texU(q))); if (p_yukKayn > 1.5 && p_yukKayn < 2.5) return texU(q).a;
  if (p_yukKayn > 2.5 && p_dokuKatmOn > 0.5) return luma(unpre(texture(s_dokuKatm, clamp(boxUV(fromUnit(q)), 0.0, 1.0))));
  float s = max(p_dokuOlce, 2.0); vec2 id = floor(q / s); float big = step(0.6, hash1(floor(id / 2.0) + 3.1)); vec2 cid = big > 0.5 ? floor(id / 2.0) * 2.0 : id; vec2 cs = vec2(big > 0.5 ? 2.0 * s : s);
  vec2 f = (q - cid * s) / cs; vec2 r = hash2(cid + 11.0) - 0.5; float e = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y));
  return 0.5 + dot(r, f - 0.5) * 0.8 + smoothstep(0.0, max(p_pah / 100.0, 0.02) + max(p_camKali, 0.5) / cs.x * 0.0, e) * 0.3; }
void main() {
  vec2 q = toUnit(here()); float e = 1.0;
  vec2 nrm = vec2(hgt(q + vec2(e, 0.0)) - hgt(q - vec2(e, 0.0)), hgt(q + vec2(0.0, e)) - hgt(q - vec2(0.0, e))) * (p_yukKayn < 0.5 ? 12.0 : 25.0);
  if (p_dokuKatmOn > 0.5 && p_yukKayn < 0.5) { vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec2 ee = 2.0 / u_box.zw;
    nrm = vec2(luma(unpre(texture(s_dokuKatm, b + vec2(ee.x, 0.0)))) - luma(unpre(texture(s_dokuKatm, b - vec2(ee.x, 0.0)))), luma(unpre(texture(s_dokuKatm, b + vec2(0.0, ee.y)))) - luma(unpre(texture(s_dokuKatm, b - vec2(0.0, ee.y))))) * 4.0; }
  if (p_puruz > 0.0) { vec2 pp = q / max(p_puruzOlcek / 100.0 * 6.0, 0.1) + radians(p_puruzEvrim); nrm += vec2(pnoise(pp), pnoise(pp + 7.0)) * p_puruz / 100.0 * 0.8; }
  if (p_tersHari > 0.5) nrm = -nrm;
  vec2 dd = nrm * p_kirilma; vec2 pa = nrm * p_prizmaAyri; int N = int(clamp(p_ornek, 1.0, 8.0)); vec4 g = vec4(0.0); float rr = 0.0, bb = 0.0;
  for (int i = 0; i < 8; i++) { if (i >= N) break; vec2 j = (hash2(vec2(float(i), 3.0)) - 0.5) * 1.2 * step(1.5, float(N)); vec4 x = texU(q + dd + j); g += x; rr += texU(q + dd + pa + j).r; bb += texU(q + dd - pa + j).b; }
  g /= float(N); rr /= float(N); bb /= float(N);
  vec4 c = vec4(rr, g.g, bb, g.a); vec3 cc = c.a > 0.0 ? c.rgb / c.a : vec3(0.0); cc = mix(cc, cc * c_camRenk, p_renkGuc / 100.0);
  if (p_isikTur > 0.5) { vec3 n3 = normalize(vec3(-nrm * 0.5, 1.0)); vec3 L = p_isikTur < 1.5 ? normalize(vec3(p_isikKonum - q, p_isikYuk)) : normalize(vec3(cos(radians(-45.0)), sin(radians(-45.0)), 0.8));
    float dif = max(dot(n3, L), 0.0); float sp = pow(max(dot(reflect(-L, n3), vec3(0, 0, 1)), 0.0), max(p_keskin, 1.0)) * p_yParlak / 100.0;
    cc = cc * (p_ortam / 100.0 + (1.0 - p_ortam / 100.0) * mix(1.0, dif, 0.5) * p_isikGuc / 100.0) + c_isikRenk * sp * p_isikGuc / 100.0; }
  o = pre(clamp(cc, 0.0, 1.0), c.a);
}
