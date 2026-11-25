// replacecolor
uniform vec3 c_from; uniform vec3 c_to; uniform float p_tol; uniform float p_soft;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 a = rgb2hsv(c), f = rgb2hsv(c_from);
  float dh = abs(a.x - f.x); dh = min(dh, 1.0 - dh);
  float d = dh * 2.0 + abs(a.y - f.y) * 0.5 + abs(a.z - f.z) * 0.25;
  float tol = p_tol / 100.0 * 0.6, sf = max(0.001, p_soft / 100.0 * 0.4);
  float k = 1.0 - smoothstep(tol, tol + sf, d);
  vec3 tgt = rgb2hsv(c_to); vec3 rep = hsv2rgb(vec3(tgt.x, tgt.y * mix(1.0, a.y / max(0.01, f.y), 0.5), clamp(a.z * tgt.z / max(0.05, f.z), 0.0, 1.0)));
  o = pre(mix(c, rep, k), s.a);
}
