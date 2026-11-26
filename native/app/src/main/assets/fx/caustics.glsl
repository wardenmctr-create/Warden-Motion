// caustics
uniform float p_desenOlce, p_isikGucu, p_kirilma, p_hiz, p_suDeri, p_kontrast, p_tohum; uniform vec3 c_isikReng;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = toUnit(here()) / max(p_desenOlce, 1.0) + seedf(p_tohum); float t = u_t * p_hiz * 0.5;
  vec2 w = vec2(pnoise(p + t), pnoise(p - t + 3.0)) * p_kirilma / 100.0; vec4 v = voronoi(p * 1.5 + w); float c = pow(clamp(1.0 - (v.y - v.x) * 3.0, 0.0, 1.0), mix(2.0, 8.0, p_kontrast / 100.0));
  vec3 col = unpre(s) + c_isikReng * c * p_isikGucu / 100.0 * 1.2; o = pre(clamp(col, 0.0, 1.0), s.a); }
