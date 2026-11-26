// frametimes
INCLUDE(_hist)
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_zamanOlce, p_uzunKareIsar, p_uyariEsig;
// Alt şeritte son karelerin süreleri: art arda aynı kalan kareler tek uzun kare sayılır; uyarı eşiğini aşanlar kırmızı
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float n = histN(); if (b.y < 0.86 || n < 2.0) { o = s; return; } vec4 res = overPre(vec4(0.04, 0.05, 0.08, 0.85), s);
  float x = 1.0 - b.x; float idx = floor(x * (n - 1.0)); float run = 1.0; for (int k = 0; k < 15; k++) { if (float(k) >= n - 1.0) break; float d = 0.0; for (int j = 0; j < 3; j++) for (int i = 0; i < 3; i++) { vec2 uv = (vec2(i, j) + 0.5) / 3.0; d += length(hist(float(k), uv).rgb - hist(float(k + 1), uv).rgb); }
    if (float(k) >= idx && d < 0.02) run += 1.0; else if (float(k) >= idx) break; }
  float ms = run * 1000.0 / 30.0; float h = clamp(ms / max(p_uyariEsig * 2.0, 1.0), 0.05, 1.0); bool warn = p_uzunKareIsar > 0.5 && ms > p_uyariEsig; float yb = 0.98 - h * 0.1;
  if (b.y > yb && fract(x * (n - 1.0)) > 0.12) res = vec4(warn ? vec3(1.0, 0.3, 0.25) : vec3(0.35, 0.85, 0.5), 1.0); o = res; }
