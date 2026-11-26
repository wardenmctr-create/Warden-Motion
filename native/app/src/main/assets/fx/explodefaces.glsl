// explodefaces
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_ayirmaMesa, p_donus, p_yuzOlce;
float sdf(vec3 p) { float cs = 30.0; vec2 id = floor(p.xy / cs); float d = 1e5;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 cid = id + vec2(i, j); vec2 c = (cid + 0.5) * cs; if (cardA(c) < 0.3) continue; vec2 h = hash2(cid) - 0.5; vec3 off = vec3(h * p_ayirmaMesa * 0.5, (hash1(cid + 3.0) - 0.3) * p_ayirmaMesa);
    vec3 q = p - vec3(c, 0.0) - off; float a = radians(p_donus) * (h.x * 2.0); q.xz = mat2(cos(a), -sin(a), sin(a), cos(a)) * q.xz; vec3 b = vec3(cs * 0.5 * p_yuzOlce / 100.0, cs * 0.5 * p_yuzOlce / 100.0, 5.0); vec3 dd = abs(q) - b; d = min(d, length(max(dd, 0.0)) + min(max(dd.x, max(dd.y, dd.z)), 0.0)); }
  return d; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
