// buildorder
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_ilerleme, p_sira, p_tohum;
float ord(vec2 id, vec2 c) { return p_sira < 0.5 ? (id.y * 40.0 + id.x) / 1600.0 + 0.5 : p_sira < 1.5 ? (c.y / boxU().y + 0.5) : hash1(id + seedf(p_tohum)); }
float sdf(vec3 p) { float cs = 20.0; vec2 id = floor(p.xy / cs); float d = 1e5; float pr = p_ilerleme / 100.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 cid = id + vec2(i, j); vec2 c = (cid + 0.5) * cs; if (cardA(c) < 0.3) continue; float k = clamp((pr * 1.3 - ord(cid, c)) * 4.0, 0.0, 1.0); if (k <= 0.0) continue;
    vec3 q = p - vec3(c, (1.0 - k) * 120.0); vec3 dd = abs(q) - vec3(cs * 0.48 * k, cs * 0.48 * k, 6.0); d = min(d, length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0)); }
  return d; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
