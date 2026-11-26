// ring3d
INCLUDE(_3d)
uniform float p_disYari, p_icYari, p_kalinlik, p_yayAcis, p_pah, p_segment;
float sdf(vec3 p) { float ro = max(p_disYari, 1.0), ri = clamp(p_icYari, 0.0, ro - 0.5); float r = length(p.xz); vec2 d = vec2(max(r - ro, ri - r), abs(p.y) - max(p_kalinlik, 1.0) * 0.5);
  float s = min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - p_pah * 0.3;
  if (abs(p_yayAcis) < 359.0) { float a = degrees(atan(p.z, p.x)) + 180.0; if (a > abs(p_yayAcis)) s = max(s, 2.0); } return s; }
vec4 surf(vec3 p, vec3 n) { float u = atan(p.z, p.x) / TAU + 0.5; float v = (length(p.xz) - p_icYari) / max(p_disYari - p_icYari, 1.0); vec4 c = layerAt(vec2(u, abs(n.y) > 0.7 ? v : 0.5 - p.y / max(p_kalinlik, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.9, 0.75, 0.3), 1.0); }
void main() { o = render3d(vec3(60.0, 0.0, 0.0)); }
