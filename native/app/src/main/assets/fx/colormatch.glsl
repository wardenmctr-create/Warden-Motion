// colormatch
uniform sampler2D s_referansKatm, s_referansDosy; uniform float p_referansKatmOn, p_referansDosyOn;
uniform float p_yontem, p_guc, p_kontrastKoru, p_alfaBoslYok;
vec4 refAt(vec2 uv) { return p_referansKatmOn > 0.5 ? texture(s_referansKatm, uv) : texture(s_referansDosy, uv); }
void main() { vec4 s = texture(u_tex, v_uv); if ((p_referansKatmOn < 0.5 && p_referansDosyOn < 0.5) || s.a <= 0.0) { o = s; return; }
  vec3 m1 = vec3(0.0), m2 = vec3(0.0), r1 = vec3(0.0), r2 = vec3(0.0); float n1 = 0.0, n2 = 0.0;
  for (int j = 0; j < 8; j++) for (int i = 0; i < 8; i++) { vec2 uv = (vec2(i, j) + 0.5) / 8.0; vec4 a = texPx(boxPx(uv)); vec4 b = refAt(uv);
    if (a.a > 0.1 || p_alfaBoslYok < 0.5) { vec3 c = unpre(a); m1 += c; m2 += c * c; n1 += 1.0; } if (b.a > 0.1 || p_alfaBoslYok < 0.5) { vec3 c = unpre(b); r1 += c; r2 += c * c; n2 += 1.0; } }
  m1 /= max(n1, 1.0); r1 /= max(n2, 1.0); vec3 sd1 = sqrt(max(m2 / max(n1, 1.0) - m1 * m1, 1e-4)), sd2 = sqrt(max(r2 / max(n2, 1.0) - r1 * r1, 1e-4));
  vec3 c = unpre(s); vec3 k = mix(sd2 / sd1, vec3(1.0), p_kontrastKoru / 100.0); vec3 t = (c - m1) * k + r1;
  if (p_yontem > 0.5 && p_yontem < 1.5) t = c + (luma(t) - luma(c)); else if (p_yontem > 1.5) t = luma(c) + (t - luma(t));
  o = pre(clamp(mix(c, t, p_guc / 100.0), 0.0, 1.0), s.a); }
