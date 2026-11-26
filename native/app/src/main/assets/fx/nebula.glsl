// nebula
uniform vec2 p_merkez; uniform float p_buyukluk, p_gazYogu, p_ayrinti, p_turbulan, p_bulutKatm, p_hareketHizi, p_yildizla, p_yildizYogu, p_derinlik, p_tohum; uniform vec3 c_birinciRenk, c_ikinciRenk, c_ucuncuRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = (toUnit(here()) - p_merkez) / max(length(boxU()) * 0.5 * p_buyukluk / 100.0, 1.0); float sd = seedf(p_tohum); vec4 acc = vec4(0.0);
  int L = int(clamp(p_bulutKatm, 1.0, 8.0));
  for (int i = 0; i < 8; i++) { if (i >= L) break; float fi = float(i); float z = 1.0 + fi * p_derinlik / 100.0 * 0.5; vec2 p = q * (2.0 + fi * 0.7) * z + vec2(u_t * p_hareketHizi * 0.002 * (1.0 + fi), fi * 3.1) + sd;
    vec2 warp = vec2(fbm01(p + 1.7, 3.0), fbm01(p + 9.2, 3.0)) * p_turbulan / 100.0 * 2.0; float f = fbm01(p + warp, 2.0 + p_ayrinti / 25.0);
    float d = smoothstep(0.95 - p_gazYogu / 100.0 * 0.7, 1.05, f * 1.25 + 0.3 - length(q) * 0.3); vec3 c = mix(mix(c_birinciRenk, c_ikinciRenk, fbm01(p * 0.7 + 4.0, 3.0)), c_ucuncuRenk, smoothstep(0.55, 0.8, f));
    acc = overPre(vec4(c, 1.0) * d * 0.7, acc); acc.rgb += c * d * 0.25 * (1.0 - acc.a); }
  if (p_yildizla > 0.5) { vec2 g = toUnit(here()) / 6.0; vec2 id = floor(g); vec2 f = fract(g) - 0.5; float h = hash1(id + sd); float st = step(1.0 - p_yildizYogu / 100.0 * 0.25, h) * (1.0 - smoothstep(0.02, 0.12, length(f - (hash2(id) - 0.5) * 0.6)));
    acc = overPre(vec4(1.0) * st * (0.6 + 0.4 * sin(u_t * 3.0 + h * 40.0)), acc); }
  o = overPre(acc, s); }
