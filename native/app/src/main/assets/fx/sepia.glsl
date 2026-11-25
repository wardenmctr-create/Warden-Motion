// sepia
uniform float p_amount;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  vec3 sp = vec3(dot(c, vec3(0.393, 0.769, 0.189)), dot(c, vec3(0.349, 0.686, 0.168)), dot(c, vec3(0.272, 0.534, 0.131))); c = mix(c, sp, clamp(p_amount / 100.0, 0.0, 1.0));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
