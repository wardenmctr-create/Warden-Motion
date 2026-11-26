// gear3d
INCLUDE(_3d)
uniform sampler2D s_baglantiDisl; uniform float p_baglantiDislOn;
uniform float p_cap, p_kalinlik, p_disSayi, p_disYuks, p_disGeni, p_merkezDeli, p_destekKoll, p_destekKoluSayi, p_donusHizi, p_baskaDislBagl, p_donusHiziDis;
float sdf(vec3 p) { float R = max(p_cap * 0.5, 4.0); float N = max(floor(p_disSayi), 3.0); float a = atan(p.y, p.x) + radians(u_t * p_donusHizi); float r = length(p.xy);
  float t = smoothstep(0.5 - p_disGeni / 200.0 - 0.08, 0.5 - p_disGeni / 200.0 + 0.08, abs(fract(a / TAU * N) - 0.5) * 2.0 * 0.5 + 0.25);
  float prof = r - (R - p_disYuks * 0.5 + p_disYuks * (1.0 - t)); float hole = (R * p_merkezDeli / 100.0) - r; float d2 = max(prof, hole);
  if (p_destekKoll > 0.5) { float M = max(floor(p_destekKoluSayi), 2.0); float sa = mod(a, TAU / M) - PI / M; float win = max(max(r - R * 0.72, R * max(p_merkezDeli / 100.0 + 0.12, 0.3) - r), abs(sa) * r - (R * 0.72 * PI / M - R * 0.1)); d2 = max(d2, -win); }
  return max(d2, abs(p.z) - max(p_kalinlik, 1.0) * 0.5); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p.xy / max(p_cap, 1.0) + 0.5; uv.y = 1.0 - uv.y; vec4 c = abs(n.z) > 0.6 ? layerAt(uv) : vec4(c_tabanRenk * 0.8, 1.0); return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
