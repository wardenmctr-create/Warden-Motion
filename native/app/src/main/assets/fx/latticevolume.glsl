// latticevolume
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_hucre, p_cubukKali, p_kafes, p_yuzeyeKirp;
// İç hacim kafes çubuklarıyla dolu: küp (eksen çubukları) ya da çapraz; isteğe bağlı silüete kırpılır
float bars(vec3 p) { float h = max(p_hucre, 2.0); float r = max(p_cubukKali, 0.3) * 0.5; vec3 q = p; if (p_kafes > 0.5) { q = vec3(p.x + p.y, p.y - p.x, p.z * 1.41421) * 0.70710678; }
  vec3 m = mod(q + h * 0.5, h) - h * 0.5; return min(min(length(m.xy), length(m.yz)), length(m.xz)) - r; }
float sdf(vec3 p) { float vol = p_yuzeyeKirp > 0.5 ? cardD(p, 40.0) : max(max(abs(p.x) - boxU().x * 0.5, abs(p.y) - boxU().y * 0.5), abs(p.z) - 20.0); return max(vol, bars(p)); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); return vec4(mix(c.rgb, vec3(0.85, 0.88, 0.95), 0.35), 1.0); }
void main() { o = render3d(vec3(0.0)); }
