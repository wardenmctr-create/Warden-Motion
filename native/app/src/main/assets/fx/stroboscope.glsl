// stroboscope
INCLUDE(_hist)
uniform sampler2D s_nesneMask; uniform float p_nesneMaskOn, p_poz, p_zamanAral, p_arkaPlanSabi;
// Sabit kamerada nesnenin geçmiş konumları: her eski kare, sabit arka plandan (şeridin medyanına yakın) farklı olduğu yerde üst üste konur
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } vec4 bg = s; if (p_arkaPlanSabi > 0.5) { vec4 a = hist(0.0, v_uv), c = hist(n - 1.0, v_uv), d = hist(floor(n * 0.5), v_uv); bg = (a + c + d) / 3.0; }
  vec4 res = s; for (int k = 1; k < 16; k++) { if (float(k) >= n) break; vec4 c = hist(float(k), v_uv); float m = p_nesneMaskOn > 0.5 ? texture(s_nesneMask, v_uv).a : smoothstep(0.08, 0.2, length(c.rgb - bg.rgb)); float cur = smoothstep(0.08, 0.2, length(s.rgb - bg.rgb));
    res = mix(res, c, m * (1.0 - cur) * (1.0 - float(k) / n * 0.4)); } o = res; }
