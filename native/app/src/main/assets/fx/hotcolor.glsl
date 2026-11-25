// hotcolor
uniform float p_shift; uniform float p_mix;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  float l = clamp(luma(c) + p_shift * 0.5, 0.0, 1.0);
  vec3 h = l < 0.25 ? mix(vec3(0.0,0.0,0.15), vec3(0.45,0.0,0.65), l / 0.25) : l < 0.5 ? mix(vec3(0.45,0.0,0.65), vec3(0.95,0.1,0.15), (l - 0.25) / 0.25) : l < 0.75 ? mix(vec3(0.95,0.1,0.15), vec3(1.0,0.75,0.0), (l - 0.5) / 0.25) : mix(vec3(1.0,0.75,0.0), vec3(1.0,1.0,0.9), (l - 0.75) / 0.25);
  c = mix(c, h, p_mix / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
