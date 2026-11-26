// ringplanet
INCLUDE(_3d)
uniform float p_gezegenGovd, p_gezegenBuyu, p_icHalkYari, p_disHalkYari, p_halkaSayi, p_halkaBosl, p_halkaKali, p_parcacikYogu, p_halkaOpak, p_donusHizi, p_karsilikGolg; uniform vec3 p_halkaEgim, c_anaRenk, c_ikinciRenk;
float Rp() { return max(p_gezegenBuyu * 0.5, 2.0); }
vec3 ringP(vec3 p) { return rotXYZ(-p_halkaEgim) * p; }
float ringD(vec3 p) { vec3 r = ringP(p); float ri = Rp() * p_icHalkYari / 100.0, ro = Rp() * max(p_disHalkYari, p_icHalkYari + 1.0) / 100.0; float l = length(r.xz); return max(abs(r.y) - max(p_halkaKali * 0.5, 0.3), max(ri - l, l - ro)); }
float sdf(vec3 p) { float s = p_gezegenGovd > 0.5 ? length(p) - Rp() : 1e5; return min(s, ringD(p)); }
float ringA(vec3 p) { vec3 r = ringP(p); float ri = Rp() * p_icHalkYari / 100.0, ro = Rp() * max(p_disHalkYari, p_icHalkYari + 1.0) / 100.0; float x = clamp((length(r.xz) - ri) / max(ro - ri, 1.0), 0.0, 1.0);
  float N = max(p_halkaSayi, 1.0); float band = fract(x * N); float gap = step(band, 1.0 - p_halkaBosl / 100.0); float id = floor(x * N);
  float grain = mix(1.0, vnoise(vec2(x * 300.0, atan(r.z, r.x) * 40.0 + u_t * p_donusHizi * 0.05)), 1.0 - p_parcacikYogu / 100.0);
  return gap * (0.55 + 0.45 * hash1(vec2(id, 7.0))) * grain * smoothstep(0.0, 0.02, x) * smoothstep(1.0, 0.98, x); }
vec4 surf(vec3 p, vec3 n) { vec3 L = normalize(vec3(-0.6, 0.5, 0.6));
  if (ringD(p) < 0.6 && !(p_gezegenGovd > 0.5 && length(p) - Rp() < 0.6)) { vec3 r = ringP(p); float x = length(r.xz) / Rp(); vec3 c = mix(c_anaRenk, c_ikinciRenk, fract(x * 3.7) * 0.6);
    float sh = 1.0; if (p_karsilikGolg > 0.5 && p_gezegenGovd > 0.5) { float b = dot(p, L); vec3 cl = p - L * b; sh = (b < 0.0 && length(cl) < Rp()) ? 0.25 : 1.0; }
    return vec4(c * sh, ringA(p) * p_halkaOpak / 100.0); }
  vec3 d = normalize(p); float lat = d.y; float b = sin((lat * 6.0 + fbm01(vec2(atan(d.x, d.z) * 2.0, lat * 20.0), 3.0) * 0.4) * PI * 2.0) * 0.5 + 0.5; vec3 c = mix(c_anaRenk, c_ikinciRenk, b * 0.5);
  if (p_karsilikGolg > 0.5) { vec3 rp = ringP(p); vec3 rl = ringP(L); float t = -rp.y / (abs(rl.y) > 1e-3 ? rl.y : 1e-3); if (t > 0.0) { vec3 h = p + L * t; float a = ringA(h); c *= 1.0 - a * 0.6 * p_halkaOpak / 100.0; } }
  return vec4(c, 1.0); }
void main() { o = render3d(vec3(0.0, u_t * p_donusHizi * 0.0, 0.0)); }
