// planet3d
INCLUDE(_3d)
uniform float p_gezegenTuru, p_buyukluk, p_yuzeyAyri, p_kraterYogu, p_kraterBuyu, p_yuzeyYuks, p_bulutSeriSayi, p_firtinaYogu, p_atmosferKali, p_tohum; uniform vec3 c_anaRenk, c_ikinciRenk, c_atmosferReng;
float R0() { return max(p_buyukluk * 0.5, 2.0); }
vec2 sph(vec3 p) { vec3 d = normalize(p); return vec2(atan(d.x, d.z) / TAU + 0.5, asin(clamp(d.y, -1.0, 1.0)) / PI + 0.5); }
float crater(vec2 uv) { if (p_kraterYogu <= 0.0) return 0.0; float sc = max(R0() * 2.0 / max(p_kraterBuyu, 1.0), 1.0); vec4 v = voronoi(uv * vec2(2.0, 1.0) * sc + seedf(p_tohum));
  float keep = step(hash1(v.zw + 3.1), p_kraterYogu / 100.0); float r = 0.35 + 0.3 * hash1(v.zw); float x = v.x / r; return keep * (x < 1.0 ? (x * x - 0.7) : smoothstep(1.4, 1.0, x) * 0.3); }
float hgt(vec3 p) { if (p_gezegenTuru > 0.5 && p_gezegenTuru < 1.5) return 0.0; vec2 uv = sph(p); return (fbm01(uv * vec2(12.0, 6.0) + seedf(p_tohum), 4.0) - 0.5) * p_yuzeyAyri / 100.0 + crater(uv) * 0.6; }
float sdf(vec3 p) { return length(p) - R0() - hgt(p) * R0() * p_yuzeyYuks / 100.0 * 0.4; }
vec4 surf(vec3 p, vec3 n) {
  vec2 uv = sph(p); float sd = seedf(p_tohum); float k = p_gezegenTuru; vec3 c;
  if (k > 0.5 && k < 1.5) { float y = uv.y * max(p_bulutSeriSayi, 1.0); float w = fbm01(vec2(uv.x * 6.0 + u_t * 0.01, uv.y * 40.0) + sd, 4.0); float b = sin((y + w * 0.6) * PI) * 0.5 + 0.5;
    c = mix(c_anaRenk, c_ikinciRenk, b); vec2 st = vec2(fract(uv.x * 3.0 + sd), uv.y) - vec2(0.5, 0.38); float spot = smoothstep(0.08, 0.0, length(st * vec2(1.0, 2.2))) * step(0.3, p_firtinaYogu / 100.0); c = mix(c, c_ikinciRenk * 0.7, spot); }
  else { float h = hgt(p); float f = fbm01(uv * vec2(16.0, 8.0) + sd * 1.7, 5.0); c = mix(c_anaRenk, c_ikinciRenk, smoothstep(0.35, 0.7, f));
    if (k > 1.5 && k < 2.5) c = mix(vec3(0.85, 0.93, 1.0), c_anaRenk, f * 0.5);
    if (k > 3.5 && k < 4.5) c = mix(c_anaRenk * 0.5, c_ikinciRenk * 1.6, smoothstep(0.62, 0.66, f) + smoothstep(0.02, 0.0, abs(fract(f * 7.0) - 0.5) - 0.45) * 0.0);
    if (k > 4.5) c = mix(vec3(0.05, 0.2, 0.55), mix(c_anaRenk, c_ikinciRenk, f), smoothstep(0.55, 0.6, f));
    c *= 0.85 + h * 0.6; }
  return vec4(c, 1.0);
}
void main() { vec4 c = render3d(vec3(0.0)); vec2 q = toUnit(here()) - p_konumXY.xy; float r = length(q) / (R0() * objScale().x); float th = p_atmosferKali / 100.0;
  float halo = (smoothstep(1.0 + th * 2.5, 1.0, r) * step(0.98, r) * 0.8 + smoothstep(1.0 - th * 2.0, 1.0, r) * step(r, 1.0) * 0.45) * step(0.0001, th); o = overPre(vec4(c_atmosferReng, 1.0) * halo, c); }
