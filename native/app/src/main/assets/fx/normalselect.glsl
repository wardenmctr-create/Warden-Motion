// normalselect
uniform vec2 p_yon; uniform float p_aciAral, p_yumusatm;
void main() { vec4 s = texture(u_tex, v_uv); float e = 1.5 * u_s; float hx = luma(unpre(texPx(here() + vec2(e, 0.0)))) - luma(unpre(texPx(here() - vec2(e, 0.0)))); float hy = luma(unpre(texPx(here() + vec2(0.0, e)))) - luma(unpre(texPx(here() - vec2(0.0, e))));
  vec3 n = normalize(vec3(-hx * 4.0, -hy * 4.0, 1.0)); vec3 d = normalize(vec3(p_yon, sqrt(max(0.0, 1.0 - dot(p_yon, p_yon))) + 0.001)); float ang = degrees(acos(clamp(dot(n, d), -1.0, 1.0)));
  float m = 1.0 - smoothstep(p_aciAral, p_aciAral + max(p_yumusatm, 0.1), ang); o = pre(unpre(s), s.a * m); }
