// edgeextend
uniform float p_uzatma, p_alfayiDegi, p_yontem, p_onizlemeUzatRgb;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a > 0.99) { o = s; return; } float R = max(p_uzatma, 0.0) * u_s; vec3 acc = vec3(0.0); float ws = 0.0; vec3 best = vec3(0.0); float bd = 1e9;
  for (int i = 0; i < 16; i++) { float a = float(i) * 0.3927; for (int k = 1; k <= 12; k++) { float t = R * float(k) / 12.0; vec4 n = texPx(here() + vec2(cos(a), sin(a)) * t); if (n.a > 0.5) { vec3 c = n.rgb / n.a; float w = 1.0 / (t + 1.0); acc += c * w; ws += w; if (t < bd) { bd = t; best = c; } break; } } }
  if (ws <= 0.0) { o = s; return; } vec3 c = p_yontem < 0.5 ? best : acc / ws; float a = p_alfayiDegi > 0.5 ? s.a : 1.0; if (p_onizlemeUzatRgb > 0.5 && u_export < 0.5) a = 1.0; o = vec4(mix(c, s.a > 0.0 ? s.rgb / s.a : c, s.a) * a, a); }
