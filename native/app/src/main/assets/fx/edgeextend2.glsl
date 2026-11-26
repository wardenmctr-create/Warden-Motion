// edgeextend2
INCLUDE(_hist)
uniform float p_genislet, p_aramaKare, p_kenarGeci, p_yoksaSeffBira;
// Kutunun dışındaki pay: komşu karelerde orada görünen içerik (kare şeridi) yoksa kenardan uzatılmış bulanık renk; kenarda yumuşak geçiş
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 inb = clamp(b, 0.0, 1.0); float out2 = length((b - inb) * u_box.zw); if (out2 <= 0.0) { o = s; return; } if (out2 > p_genislet * u_s) { o = vec4(0.0); return; }
  vec4 acc = vec4(0.0); float w = 0.0; float n = histN(); for (int k = 0; k < 9; k++) { if (float(k) >= n) break; vec4 c = hist(float(k), v_uv); if (c.a > 0.5) { acc += c; w += 1.0; } }
  vec4 ext = vec4(0.0); for (int i = 0; i < 6; i++) ext += texPx(boxPx(inb) - normalize(b - inb + 1e-6) * float(i) * 3.0 * u_s); ext /= 6.0;
  vec4 c = w > 0.0 ? acc / w : (p_yoksaSeffBira > 0.5 ? vec4(0.0) : ext); float fade = 1.0 - smoothstep(0.0, max(p_kenarGeci * u_s, 1.0) + p_genislet * u_s * 0.5, out2) * 0.6; o = c * fade; }
