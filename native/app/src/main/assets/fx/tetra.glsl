// tetra
INCLUDE(_3d)
uniform float p_boyut, p_yuksekliOran, p_yuzDoku, p_kenarCizg;
float sdf(vec3 p) { float s = max(p_boyut, 1.0) * 0.35; p.y /= max(p_yuksekliOran, 0.1); return (max(abs(p.x + p.y) - p.z, abs(p.x - p.y) + p.z) - s) * 0.57735 * min(1.0, p_yuksekliOran); }
vec4 surf(vec3 p, vec3 n) { vec4 c = layerAt(vec2(p.x, -p.y) / max(p_boyut, 1.0) + 0.5 + n.xy * 0.1); vec3 col = c.a > 0.0 ? c.rgb / c.a : vec3(0.85);
  if (p_kenarCizg > 0.5) { float e = abs(sdf(p + n * 2.0)); col *= 1.0; } return vec4(col, 1.0); }
void main() { o = render3d(vec3(35.0, 25.0, 0.0)); }
