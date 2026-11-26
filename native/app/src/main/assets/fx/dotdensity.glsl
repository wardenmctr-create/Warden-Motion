// dotdensity
INCLUDE(_chart)
uniform float p_noktaDege, p_noktaCapi, p_tohum;
// Satır: x %, y %, değer → değer / nokta değeri kadar eşit nokta, konum çevresinde diske tohumlu dağılır (katmanın alfası içinde)
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = here(); int N = int(min(dR(), 32.0)); float sp = max(p_noktaCapi * 2.5, 4.0) * u_s; vec2 id = floor(q / sp); float v = 0.0;
  for (int r = 0; r < 32; r++) { if (r >= N) break; vec2 c = boxPx(vec2(dat(float(r), 0.0), dat(float(r), 1.0)) / 100.0); float cnt = min(abs(dat(float(r), 2.0)) / max(p_noktaDege, 1e-6) * 1000.0, 2000.0); float R = sqrt(cnt) * sp * 0.6;
    if (length(q - c) > R + sp) continue; float dens = cnt / max(3.14159 * R * R / (sp * sp), 1.0);
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 cell = id + vec2(i, j); vec2 pt = (cell + 0.2 + hash2(cell + p_tohum + float(r) * 7.1) * 0.6) * sp; if (length(pt - c) > R || hash1(cell * 1.3 + float(r) + p_tohum) > dens) continue;
      if (texPx(pt).a < 0.3 && s.a > 0.0) continue; v = max(v, 1.0 - smoothstep(p_noktaCapi * u_s * 0.5 - 0.7, p_noktaCapi * u_s * 0.5 + 0.7, length(q - pt))); } }
  o = overPre(vec4(0.95, 0.35, 0.25, 1.0) * v, s); }
