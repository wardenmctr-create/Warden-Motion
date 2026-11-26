// darkglow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_karistir, p_yalnizHale;
void main() {
  vec4 s = texture(u_src, v_uv); float h = clamp(texture(u_aux, v_uv).a * p_yogunluk / 100.0 * 1.8, 0.0, 1.0);
  if (p_yalnizHale > 0.5) { o = vec4(c_renk, 1.0) * h; return; }
  vec3 c = unpre(s); vec3 r = p_karistir < 0.5 ? c * mix(vec3(1.0), c_renk, h) : mix(c, c_renk, h);
  float a = max(s.a, h * (1.0 - s.a) * (p_karistir < 0.5 ? 1.0 : 1.0));
  o = s.a > 0.0 ? pre(r, s.a) + vec4(c_renk, 1.0) * h * (1.0 - s.a) : vec4(c_renk, 1.0) * h;
}
