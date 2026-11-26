// dehaze
uniform float p_pusGide, p_ortamIsig, p_enDusuGeci, p_tahminAlan, p_gokyuzuKoru, p_kenarKoru, p_renkKoru; uniform vec3 c_ortamReng;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 I = unpre(s); float R = max(p_tahminAlan * u_s, 1.0); float dark = 1.0;
  for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * R * (0.4 + 0.6 * fract(float(i) * 0.618)))); dark = min(dark, min(c.r, min(c.g, c.b))); }
  dark = mix(dark, min(I.r, min(I.g, I.b)), p_kenarKoru / 100.0 * 0.5);
  vec3 A = p_ortamIsig > 0.5 ? c_ortamReng : vec3(0.85, 0.88, 0.92); float t = max(1.0 - p_pusGide / 100.0 * 0.95 * dark / max(luma(A), 0.1), p_enDusuGeci / 100.0);
  float sky = smoothstep(0.7, 0.95, luma(I)) * (1.0 - smoothstep(0.05, 0.25, length(I - luma(I)))) * p_gokyuzuKoru / 100.0; t = mix(t, 1.0, sky);
  vec3 J = (I - A) / t + A; vec3 r = mix(J, J * (luma(I) / max(luma(J), 1e-3)) * 0.0 + J, 1.0); r = mix(r, satAdj(r, 1.0 - (1.0 - t) * 0.3), p_renkKoru / 100.0);
  o = pre(clamp(r, 0.0, 1.0), s.a); }
