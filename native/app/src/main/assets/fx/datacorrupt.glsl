// datacorrupt
uniform float p_bozulmaMikt, p_blokBuyu, p_blokYogu, p_blokKaym, p_hareketYayi, p_renkBozu, p_cozunurl, p_oncekiKareTasi, p_kareHafi, p_donmusBlokSure, p_yenilenmAral, p_otomatikTeti, p_elleTeti, p_hareketYonuTaki, p_sahneDegiHafi, p_aniParlDegi, p_tohum;
void main() { vec2 px = here(); float amt = (p_otomatikTeti > 0.5 ? p_bozulmaMikt : p_elleTeti) / 100.0; float tick = floor(u_t * 24.0 / max(p_yenilenmAral, 1.0)); float sd = seedf(p_tohum);
  float bs = max(p_blokBuyu, 2.0) * u_s; vec2 bid = floor(px / bs); float h = hash1(bid + sd + tick * 0.37); float frozen = floor(u_t * 24.0 / max(p_donmusBlokSure, 1.0));
  vec4 c = texture(u_tex, v_uv);
  if (h < p_blokYogu / 100.0 * amt * 1.5) { vec2 hh = hash2(bid + frozen + sd); vec2 off = (hh - 0.5) * 2.0 * p_blokKaym * u_s;
    vec2 mv = p_hareketYonuTaki > 0.5 ? lumGrad(bid * bs, bs) : vec2(0.0); vec2 smear = normalize(mv + vec2(1e-3, 0.0)) * fract(px.x / bs) * bs * p_hareketYayi / 100.0 * 2.0;
    vec2 src = bid * bs + mod(px, bs) * mix(1.0, 0.25, step(0.7, hh.x) * p_oncekiKareTasi / 100.0) + off + smear; c = texPx(src);
    float rl = mix(1.0, 8.0, 1.0 - p_cozunurl / 100.0); vec2 cs = floor(px / (rl * u_s)) * rl * u_s; c = mix(c, texPx(cs + off), 1.0 - p_cozunurl / 100.0);
    if (hash1(bid + 5.0 + tick) < p_renkBozu / 100.0) { vec3 u = unpre(c); u = vec3(u.g, u.b * 1.2, u.r) * vec3(1.1, 0.9, 1.2); c = pre(clamp(u, 0.0, 1.0), c.a); }
    if (p_aniParlDegi > 0.5 && hash1(bid + 11.0 + tick) < 0.08 * amt) c.rgb = min(c.rgb * 1.8, vec3(c.a)); }
  else if (hash1(vec2(bid.y, tick + 3.0)) < amt * 0.15) { c = texPx(px + vec2((hash1(vec2(bid.y, tick)) - 0.5) * p_blokKaym * u_s, 0.0)); }
  o = c; }
