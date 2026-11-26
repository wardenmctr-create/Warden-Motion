// tiltshift_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec2 p_odakMerk; uniform float p_aci, p_netBantGeni, p_gecisGeni, p_disAlanDoyg, p_tersMask;
void main() {
  vec2 q = toUnit(here()); float a = radians(p_aci); vec2 n = vec2(-sin(a), cos(a)); float H = abs(dot(boxU(), abs(n)));
  float d = abs(dot(q - p_odakMerk, n)) / max(H, 1.0); float b = p_netBantGeni / 200.0, g = max(p_gecisGeni / 100.0, 0.01);
  float m = smoothstep(b, b + g, d); if (p_tersMask > 0.5) m = 1.0 - m;
  vec4 s = texture(u_src, v_uv), bl = texture(u_aux, v_uv); vec4 c = mix(s, bl, m);
  if (c.a > 0.0) c = pre(satAdj(c.rgb / c.a, 1.0 + p_disAlanDoyg / 100.0 * m), c.a);
  o = c;
}
