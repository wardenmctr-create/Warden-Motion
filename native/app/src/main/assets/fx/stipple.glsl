// stipple
uniform float p_size; uniform vec3 c_col; uniform vec3 c_bg;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 px = v_uv * u_res; float sz = p_size * u_s; vec2 cell = floor(px / sz); float l = luma(unpre(s)); float ink = 0.0;
  for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) { vec2 cc = cell + vec2(x, y); vec2 j = hash2(cc); vec2 p = (cc + j) * sz; float on = step(hash1(cc + 3.1), (1.0 - l) * 1.05); ink = max(ink, on * (1.0 - smoothstep(sz * 0.32, sz * 0.42, length(px - p)))); }
  o = pre(mix(c_bg, c_col, ink), s.a);
}
