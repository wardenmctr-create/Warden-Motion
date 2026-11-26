// linesweep
uniform float p_ilerleme, p_cizgiSayi, p_aci, p_cizgiGeni, p_gecikme, p_yumusatm, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = rot2(-p_aci) * toUnit(here()); vec2 B = boxU(); float n = max(1.0, floor(p_cizgiSayi)); float y = (p.y / B.y + 0.5) * n; float id = floor(y);
  float delay = id / n * p_gecikme / 100.0; float pp = clamp((p_ilerleme / 100.0 - delay) / max(1.0 - p_gecikme / 100.0, 0.05), 0.0, 1.0); float x = p.x / B.x + 0.5;
  float on = step(x, pp) * step(abs(fract(y) - 0.5) * 2.0, 1.0 - p_cizgiGeni / 100.0 * (1.0 - pp)); if (p_ters > 0.5) on = 1.0 - on; o = s * on; }
