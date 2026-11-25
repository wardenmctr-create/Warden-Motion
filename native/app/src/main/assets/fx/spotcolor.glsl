// spotcolor
uniform vec3 c_keep; uniform float p_tol; uniform float p_soft;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 a = rgb2hsv(c), f = rgb2hsv(c_keep);
  float dh = abs(a.x - f.x); dh = min(dh, 1.0 - dh); float d = dh * 2.0 + max(0.0, f.y - a.y) * 0.6;
  float tol = p_tol / 100.0 * 0.6, sf = max(0.001, p_soft / 100.0 * 0.4);
  float k = 1.0 - smoothstep(tol, tol + sf, d);
  o = pre(mix(vec3(luma(c)), c, k), s.a);
}
