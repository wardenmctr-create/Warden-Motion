// colormatchtrans
uniform float p_tolerans, p_ilerleme; uniform vec3 c_referansRenk;
void main() { vec4 s = texture(u_tex, v_uv); float p = p_ilerleme / 100.0; vec3 c = unpre(s); float d = length(c - c_referansRenk) / 1.732; float near = 1.0 - smoothstep(p_tolerans / 100.0 * 0.6, p_tolerans / 100.0 * 0.6 + 0.1, d);
  vec3 r = mix(c, c_referansRenk, smoothstep(0.0, 0.5, p)); float a = s.a * (1.0 - smoothstep(0.5 + near * 0.3, 1.0, p)); o = pre(r, a); }
