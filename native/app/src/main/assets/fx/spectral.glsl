// spectral
uniform float p_shift; uniform float p_rep; uniform float p_mix;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c = mix(c, hsv2rgb(vec3(fract(luma(c) * p_rep * 0.85 + p_shift), 0.85, 1.0)), p_mix / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
