// waveform
uniform sampler2D s_anl; uniform float p_anlOn, p_parlakliRgb, p_cizgiGucu, p_referansCizg;
void main() { vec2 b = boxUV(here()); vec4 bg = vec4(0.03, 0.04, 0.07, 0.9); float k = p_cizgiGucu / 100.0 * 1.6; vec3 c;
  if (p_parlakliRgb < 0.5) c = vec3(0.4, 1.0, 0.5) * texture(s_anl, b).a * k;
  else if (p_parlakliRgb < 1.5) { vec4 h = texture(s_anl, b); c = vec3(h.r, h.g, h.b) * k; }
  else { float seg = floor(b.x * 3.0); vec2 u = vec2(fract(b.x * 3.0), b.y); vec4 h = texture(s_anl, u); c = (seg < 0.5 ? vec3(h.r, 0.0, 0.0) : seg < 1.5 ? vec3(0.0, h.g, 0.0) : vec3(0.0, 0.0, h.b)) * k * 1.5; }
  vec4 r = overPre(vec4(clamp(c, 0.0, 1.0), 1.0) * min(1.0, max(c.r, max(c.g, c.b)) * 2.0), bg);
  if (p_referansCizg > 0.5) { float y = 1.0 - b.y; float ln = 0.0; for (int i = 0; i <= 4; i++) ln = max(ln, 1.0 - smoothstep(0.0, 1.5 / max(u_box.w, 1.0), abs(y - float(i) * 0.25))); r = overPre(vec4(0.6, 0.6, 0.6, 1.0) * ln * 0.5, r); }
  o = r; }
