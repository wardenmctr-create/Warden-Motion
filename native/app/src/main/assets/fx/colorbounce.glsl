// colorbounce
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_mesafe, p_guc; uniform vec2 p_yon;
void main() { vec4 s = texture(u_tex, v_uv); if (p_kaynakOn < 0.5 || s.a <= 0.0) { o = s; return; } vec2 d = length(p_yon) > 0.01 ? normalize(p_yon) : vec2(1.0, 0.0); vec3 acc = vec3(0.0); float ws = 0.0;
  for (int i = 1; i <= 10; i++) { float t = p_mesafe * float(i) / 10.0 * u_s; vec4 c = texture(s_kaynak, clamp(boxUV(here() + d * t), 0.0, 1.0)); float w = c.a * exp(-float(i) * 0.2); acc += unpre(c) * w; ws += w; }
  float edge = 1.0 - smoothstep(0.0, p_mesafe * u_s, innerDist(here(), p_mesafe * u_s)); vec3 bounce = ws > 0.0 ? acc / ws : vec3(0.0); o = pre(clamp(unpre(s) + bounce * edge * p_guc / 100.0 * 0.6 * step(0.001, ws), 0.0, 1.0), s.a); }
