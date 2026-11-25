// bevelalpha
uniform float p_width; uniform float p_ang; uniform float p_light;
const vec2 D16[16] = vec2[16](vec2(1,0),vec2(0.924,0.383),vec2(0.707,0.707),vec2(0.383,0.924),vec2(0,1),vec2(-0.383,0.924),vec2(-0.707,0.707),vec2(-0.924,0.383),vec2(-1,0),vec2(-0.924,-0.383),vec2(-0.707,-0.707),vec2(-0.383,-0.924),vec2(0,-1),vec2(0.383,-0.924),vec2(0.707,-0.707),vec2(0.924,-0.383));
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float w = max(1.0, p_width * u_s); vec2 g = vec2(0.0);
  for (int k = 1; k <= 3; k++) { float r = w * float(k) / 3.0; g += vec2(tex(v_uv + vec2(r, 0) / u_res).a - tex(v_uv - vec2(r, 0) / u_res).a, tex(v_uv + vec2(0, r) / u_res).a - tex(v_uv - vec2(0, r) / u_res).a) / float(k); }
  vec2 L = vec2(cos(radians(p_ang)), sin(radians(p_ang))); float v = dot(g, L) * p_light / 100.0;
  vec3 c = unpre(s); c = v > 0.0 ? mix(c, vec3(1.0), clamp(v, 0.0, 1.0) * 0.8) : mix(c, vec3(0.0), clamp(-v, 0.0, 1.0) * 0.7); o = pre(c, s.a);
}
