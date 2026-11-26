// starprism
INCLUDE(_3d)
uniform float p_disYari, p_icYari, p_ucSayi, p_kalinlik, p_kenarPahi, p_kapaklar;
float star2(vec2 p) { float n = clamp(floor(p_ucSayi), 3.0, 20.0); float r1 = max(p_disYari, 1.0), r2 = clamp(p_icYari, 0.5, r1); float an = PI / n; float a = atan(p.x, p.y); float bn = mod(a, 2.0 * an) - an;
  p = length(p) * vec2(cos(bn), abs(sin(bn))); vec2 A = vec2(r1, 0.0), Bq = vec2(r2 * cos(an), r2 * sin(an)); vec2 e = Bq - A; vec2 w = p - A; vec2 b = w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
  return length(b) * sign(e.x * w.y - e.y * w.x) * -1.0; }
float sdf(vec3 p) { float r = p_kenarPahi; vec2 w = vec2(star2(p.xy) + r, abs(p.z) - max(p_kalinlik, 1.0) * 0.5 + r); return (min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r) * 0.8; }
vec4 surf(vec3 p, vec3 n) { vec4 c = layerAt(vec2(p.x, -p.y) / (2.0 * max(p_disYari, 1.0)) + 0.5); vec3 col = c.a > 0.0 ? c.rgb / c.a : vec3(0.95, 0.8, 0.2); if (abs(n.z) < 0.6) col *= 0.75; return vec4(col, 1.0); }
void main() { o = render3d(vec3(0.0)); }
