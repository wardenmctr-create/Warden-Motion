// flatfield
uniform sampler2D s_duzAlan; uniform float p_duzAlanOn, p_normaliz, p_guc;
void main() { vec4 s = texture(u_tex, v_uv); if (p_duzAlanOn < 0.5) { o = s; return; } vec3 f = unpre(texture(s_duzAlan, clamp(boxUV(here()), 0.0, 1.0)));
  vec3 m = vec3(0.0); for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) m += unpre(texture(s_duzAlan, (vec2(i, j) + 0.5) / 4.0)); m /= 16.0;
  vec3 r = unpre(s) * (m * p_normaliz / 100.0) / max(f, vec3(0.02)); o = pre(clamp(mix(unpre(s), r, p_guc / 100.0), 0.0, 1.0), s.a); }
