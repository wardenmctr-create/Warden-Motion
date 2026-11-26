// starpoly
INCLUDE(_3d)
uniform float p_yaricap, p_sivrilik, p_bicim, p_yuzCizg;
float sdTet(vec3 p, float s) { return (max(abs(p.x + p.y) - p.z, abs(p.x - p.y) + p.z) - s) * 0.57735; }
float sdf(vec3 p) { float s = max(p_yaricap, 1.0) * 0.45 * p_sivrilik / 1.6; float d = min(sdTet(p, s), sdTet(vec3(p.x, -p.y, -p.z) * vec3(1.0, 1.0, 1.0), s));
  if (p_bicim > 0.5) { float d2 = min(sdTet(p.yzx, s), sdTet(vec3(p.y, -p.z, -p.x), s)); d = min(d, d2); } return d; }
vec4 surf(vec3 p, vec3 n) { vec4 c = layerAt(vec2(p.x, -p.y) / (2.0 * max(p_yaricap, 1.0)) + 0.5); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.95, 0.85, 0.3), 1.0); }
void main() { o = render3d(vec3(20.0, 30.0, 0.0)); }
