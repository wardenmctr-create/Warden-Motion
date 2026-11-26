// texsimilar
uniform sampler2D s_ornekDoku; uniform float p_ornekDokuOn, p_benzerli, p_olcekTole;
vec3 stats(bool ref, vec2 px, vec2 uv) { float m = 0.0, m2 = 0.0, g = 0.0; for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 o2 = vec2(i, j) * 3.0; float l = ref ? luma(unpre(texture(s_ornekDoku, fract(uv + o2 / 64.0)))) : luma(unpre(texPx(px + o2 * u_s))); m += l; m2 += l * l; } m /= 25.0; return vec3(m, sqrt(max(m2 / 25.0 - m * m, 0.0)), 0.0); }
void main() { vec4 s = texture(u_tex, v_uv); if (p_ornekDokuOn < 0.5) { o = s; return; } vec3 a = stats(false, here(), vec2(0.0)); vec3 b = vec3(0.0); for (int i = 0; i < 4; i++) b += stats(true, vec2(0.0), vec2(float(i) * 0.25 + 0.1, 0.4)); b /= 4.0;
  float d = abs(a.x - b.x) * 2.0 + abs(a.y - b.y) * 4.0 * (1.0 - p_olcekTole / 200.0); float sim = 1.0 - smoothstep(0.0, (1.0 - p_benzerli / 100.0) * 0.6 + 0.02, d);
  o = overPre(vec4(1.0, 0.3, 0.1, 1.0) * sim * 0.6 * s.a, s); }
