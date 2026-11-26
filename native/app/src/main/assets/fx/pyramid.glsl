// pyramid
INCLUDE(_3d)
uniform float p_tabanGeni, p_yuksekli, p_kenarSayi, p_tabanKapa, p_dokuYonu;
float sdf(vec3 p) { float n = clamp(floor(p_kenarSayi), 3.0, 12.0); float h = max(p_yuksekli, 1.0); float r = max(p_tabanGeni, 1.0) * 0.5 * cos(PI / n); float y = p.y + h * 0.5;
  float a = atan(p.z, p.x); float seg = TAU / n; float c = floor(a / seg + 0.5) * seg; float x = cos(c) * p.x + sin(c) * p.z;
  vec2 nn = normalize(vec2(h, r)); float side = dot(vec2(x, y) - vec2(r, 0.0), nn); return max(side, -y) * 0.8; }
vec4 surf(vec3 p, vec3 n) { if (n.y < -0.8) return vec4(vec3(0.8) * (p_tabanKapa > 0.5 ? 1.0 : 0.4), 1.0);
  vec2 uv = rot2(p_dokuYonu) * (vec2(p.x, p.z) / max(p_tabanGeni, 1.0)) + 0.5; uv.y = mix(uv.y, 0.5 - p.y / max(p_yuksekli, 1.0), 0.6); vec4 c = layerAt(uv); return vec4(c.a > 0.0 ? c.rgb / c.a : vec3(0.85), 1.0); }
void main() { o = render3d(vec3(0.0)); }
