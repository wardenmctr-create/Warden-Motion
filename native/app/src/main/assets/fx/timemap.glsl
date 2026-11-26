// timemap
INCLUDE(_hist)
uniform sampler2D s_zamanHari; uniform float p_zamanHariOn, p_azamiFark, p_enterpol;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 9.0) { o = s; return; } float m = p_zamanHariOn > 0.5 ? luma(unpre(texture(s_zamanHari, clamp(boxUV(here()), 0.0, 1.0)))) : boxUV(here()).y;
  float k = clamp(m * 8.0, 0.0, 8.0); o = p_enterpol > 0.5 ? mix(hist(floor(k), v_uv), hist(min(floor(k) + 1.0, 8.0), v_uv), fract(k)) : hist(floor(k + 0.5), v_uv); }
