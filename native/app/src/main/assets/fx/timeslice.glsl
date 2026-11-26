// timeslice
INCLUDE(_hist)
uniform sampler2D s_dagilimHari; uniform float p_dagilimHariOn, p_zamanFark, p_ilerleme;
void main() { vec4 s = texture(u_tex, v_uv); float p = p_ilerleme / 100.0; float m = p_dagilimHariOn > 0.5 ? luma(unpre(texture(s_dagilimHari, clamp(boxUV(here()), 0.0, 1.0)))) : boxUV(here()).x; float N = histN();
  vec4 h = N > 0.0 ? hist(clamp(m * (N - 1.0), 0.0, N - 1.0), v_uv) : s; float k = smoothstep(m - 0.1, m + 0.1, p * 1.2); o = mix(s, h, 0.6) * (1.0 - k); }
