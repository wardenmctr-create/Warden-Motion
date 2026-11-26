// chrome
uniform sampler2D s_yansimaKatm; uniform float p_yansimaKatmOn; uniform float p_yansimaAcis, p_metalik, p_puruzlul, p_kontrast; uniform vec3 c_kromTonu;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 g = lumGrad(here(), 2.0) * 8.0 + alphaGrad(here(), 2.0) * 4.0; vec3 n = normalize(vec3(-g, 1.0));
  vec3 r = reflect(vec3(0.0, 0.0, -1.0), n); vec2 env = r.xy * 0.5 + 0.5; env = rot2(p_yansimaAcis) * (env - 0.5) + 0.5;
  vec3 e = p_yansimaKatmOn > 0.5 ? unpre(texture(s_yansimaKatm, clamp(env, 0.0, 1.0))) : vec3(0.5 + 0.5 * sin(env.y * 9.0 + 1.0) * cos(env.x * 3.0)) * mix(vec3(0.4, 0.45, 0.55), vec3(1.0), smoothstep(0.3, 0.7, env.y));
  e = mix(e, vec3(luma(e)), p_puruzlul / 100.0 * 0.6); e = conAdj(e, 1.0 + p_kontrast / 100.0, 0.5);
  vec3 c = mix(unpre(s), e * c_kromTonu * (0.7 + 0.5 * luma(unpre(s))), p_metalik / 100.0);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
