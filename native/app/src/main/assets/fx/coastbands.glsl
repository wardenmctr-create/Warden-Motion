// coastbands
uniform sampler2D s_kiyiVekt; uniform vec3 c_denizReng; uniform float p_kiyiVektOn, p_bant, p_aralik, p_karaBand;
// Kara (kaynak alfa ya da katmanın kendi alfası) çevresinde denize doğru eşit aralıklı kıyı bantları; isteğe bağlı karada da
float land(vec2 px) { return p_kiyiVektOn > 0.5 ? texture(s_kiyiVekt, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float G = p_aralik * u_s; float M = G * p_bant; bool L = land(p) > 0.5; float d = 1e5;
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; for (int k = 1; k <= 24; k++) { float r = float(k) / 24.0 * M; if ((land(p + vec2(cos(a), sin(a)) * r) > 0.5) != L) { d = min(d, r); break; } } }
  if (d > M) { o = L ? s : vec4(c_denizReng * 0.8, 1.0) * (p_kiyiVektOn > 0.5 ? 1.0 : 0.0) + s * (1.0 - (p_kiyiVektOn > 0.5 ? 1.0 : 0.0)); return; }
  float band = floor(d / G); float edge = 1.0 - smoothstep(0.0, 1.2 * u_s, abs(fract(d / G) - 0.0) * G);
  if (!L) { vec3 c = mix(c_denizReng * 1.5, c_denizReng * 0.8, band / max(p_bant, 1.0)); o = vec4(mix(c, vec3(1.0), edge * 0.35), 1.0); }
  else if (p_karaBand > 0.5) { o = vec4(mix(unpre(s), vec3(0.85, 0.82, 0.6), (1.0 - band / max(p_bant, 1.0)) * 0.35) * s.a, s.a); } else o = s; }
