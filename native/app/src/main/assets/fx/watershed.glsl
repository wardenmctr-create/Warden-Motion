// watershed
uniform sampler2D s_yuksekli; uniform vec2 p_cikis; uniform vec3 c_havza; uniform float p_yuksekliOn, p_akisEsig;
// Yükseklik (kaynak ya da parlaklık): her piksel eğim boyunca aşağı yürür; ulaştığı çukura göre havza rengi; çıkış noktasına akan havza vurgulanır; vadilerde akarsu
float E(vec2 px) { return p_yuksekliOn > 0.5 ? luma(texture(s_yuksekli, boxUV(px)).rgb) : lumAt(px); }
vec2 sink(vec2 px) { vec2 p = px; float st = 3.0 * u_s; for (int k = 0; k < 40; k++) { vec2 g = vec2(E(p + vec2(st, 0.0)) - E(p - vec2(st, 0.0)), E(p + vec2(0.0, st)) - E(p - vec2(0.0, st))); if (length(g) < 1e-4) break; p -= normalize(g) * st; } return p; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); vec2 sk = floor(sink(p) / (24.0 * u_s)); vec2 so = floor(sink(fromUnit(p_cikis)) / (24.0 * u_s));
  vec3 bc = hsv2rgb(vec3(hash1(sk), 0.35, 0.9)); bool mine = sk == so; vec3 base = unpre(s); float e = E(p); float lap = E(p + vec2(4.0 * u_s, 0.0)) + E(p - vec2(4.0 * u_s, 0.0)) + E(p + vec2(0.0, 4.0 * u_s)) + E(p - vec2(0.0, 4.0 * u_s)) - 4.0 * e;
  float river = smoothstep(0.02, 0.06, lap * (100.0 / max(p_akisEsig, 1.0)) * 2.0 + lap); vec3 c = mix(base, mine ? c_havza : bc, mine ? 0.55 : 0.3); c = mix(c, vec3(0.15, 0.45, 0.95), river * 0.8); o = pre(c, max(s.a, 0.0)); }
