// motionmagnify
INCLUDE(_hist)
uniform float p_hareketBuyu, p_maksimumSapm, p_gurultuKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 3.0) { o = s; return; } vec4 avg = (hist(1.0, v_uv) + hist(2.0, v_uv)) * 0.5; vec4 d = s - avg; float n = length(d.rgb); d *= smoothstep(p_gurultuKoru / 100.0 * 0.05, p_gurultuKoru / 100.0 * 0.05 + 0.02, n);
  vec4 r = s + clamp(d * (p_hareketBuyu - 1.0), -p_maksimumSapm / 100.0, p_maksimumSapm / 100.0); o = clamp(r, 0.0, 1.0); }
