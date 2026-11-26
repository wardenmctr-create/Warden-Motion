// strokewrite
uniform float p_sira, p_ilerleme, p_kalemKali, p_orijinalGlifBirl;
// Harf iskeleti: iç uzaklığın tepe çizgisi; kalem kalınlığında iz, yazılma sırası (soldan sağa ya da yukarıdan aşağı) ilerlemeyle; sonda asıl harf belirir
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = vec4(0.0); return; } vec2 p = here(); float R = u_box.w * 0.25; float d = innerDist(p, R); float m = d;
  for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; m = max(m, innerDist(p + vec2(cos(a), sin(a)) * max(d * 0.7, 1.0), R)); }
  float pen = step(m - p_kalemKali * u_s * 0.5, d); vec2 b = boxUV(p); float ord = p_sira < 0.5 ? b.x * 0.85 + b.y * 0.15 : b.y * 0.85 + b.x * 0.15; float pr = p_ilerleme / 100.0;
  float shown = pen * smoothstep(pr + 0.01, pr - 0.01, ord); float glyph = p_orijinalGlifBirl > 0.5 ? smoothstep(0.85, 1.0, pr) : 0.0; o = s * max(shown, glyph); }
