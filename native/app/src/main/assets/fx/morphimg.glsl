// morphimg
uniform sampler2D s_hedefKatm, s_hedefGors; uniform float p_hedefKatmOn, p_hedefGorsOn;
uniform float p_alfaGeci, p_ilerleme, p_sekilEtki, p_renkEtki;
vec4 tgt(vec2 uv) { return p_hedefKatmOn > 0.5 ? texture(s_hedefKatm, uv) : texture(s_hedefGors, uv); }
float sdA(vec2 px, bool other) { // alfa sınırına işaretli uzaklık (yaklaşık, 16 ışın)
  float a0 = other ? tgt(clamp(boxUV(px), 0.0, 1.0)).a : texPx(px).a; float R = 40.0 * u_s; float best = R;
  for (int i = 0; i < 16; i++) { float ang = float(i) * TAU / 16.0; for (int k = 1; k <= 8; k++) { vec2 p = px + vec2(cos(ang), sin(ang)) * R * float(k) / 8.0; float a = other ? tgt(clamp(boxUV(p), 0.0, 1.0)).a : texPx(p).a; if ((a > 0.5) != (a0 > 0.5)) { best = min(best, R * float(k) / 8.0); break; } } }
  return a0 > 0.5 ? -best : best; }
void main() { vec4 s = texture(u_tex, v_uv); if (p_hedefKatmOn < 0.5 && p_hedefGorsOn < 0.5) { o = s; return; } float t = clamp(p_ilerleme / 100.0, 0.0, 1.0); float ts = t * p_sekilEtki / 100.0, tc = t * p_renkEtki / 100.0;
  vec2 uv = clamp(boxUV(here()), 0.0, 1.0); vec4 b = tgt(uv); float a;
  if (p_alfaGeci > 0.5) { float d = mix(sdA(here(), false), sdA(here(), true), ts); a = 1.0 - smoothstep(-1.0 * u_s, 1.0 * u_s, d); } else a = mix(s.a, b.a, ts);
  vec3 ca = s.a > 0.0 ? s.rgb / s.a : (b.a > 0.0 ? b.rgb / b.a : vec3(0.0)), cb = b.a > 0.0 ? b.rgb / b.a : ca; o = pre(mix(ca, cb, tc), a); }
