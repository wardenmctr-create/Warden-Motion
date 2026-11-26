// satlumplane
uniform float p_bolme, p_olcek, p_kaynakRenk, p_grafikOpak;
// Grafik: x = doygunluk, y = parlaklık; yoğunluk 20×20 örnekten pencere yakınlığıyla; kutunun sağ alt köşesinde
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 g = (b - vec2(0.55, 0.55)) / 0.42; if (any(lessThan(g, vec2(0.0))) || any(greaterThan(g, vec2(1.0)))) { o = s; return; }
  float N = clamp(p_bolme, 16.0, 256.0); vec2 cell = floor(g * N) / N; float cnt = 0.0; vec3 col = vec3(0.0);
  for (int j = 0; j < 20; j++) for (int i = 0; i < 20; i++) { vec4 q = texPx(boxPx((vec2(i, j) + 0.5) / 20.0)); if (q.a < 0.2) continue; vec3 h = rgb2hsv(unpre(q)); vec2 pt = vec2(h.y, 1.0 - h.z);
    if (floor(pt * N) == floor(g * N)) { cnt += 1.0; col += unpre(q); } }
  float d = p_olcek > 0.5 ? log(1.0 + cnt) / log(1.0 + 40.0) : cnt / 12.0; vec3 dot2 = p_kaynakRenk > 0.5 && cnt > 0.0 ? col / cnt : vec3(1.0);
  vec4 bg = vec4(0.06, 0.07, 0.1, 0.85); float grid = (fract(g.x * 4.0) < 0.02 || fract(g.y * 4.0) < 0.02) ? 0.15 : 0.0; bg.rgb += grid;
  vec4 gr = overPre(vec4(dot2 * clamp(d, 0.0, 1.0), clamp(d, 0.0, 1.0)), bg) * (p_grafikOpak / 100.0); o = overPre(gr, s); }
