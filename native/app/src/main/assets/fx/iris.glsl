// iris
uniform vec2 p_merkez; uniform float p_ilerleme, p_bicim, p_kenarSayi, p_yumusatm, p_aci, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 B = boxU(); vec2 r = rot2(-p_aci) * (toUnit(here()) - p_merkez); float R = length(B) * 0.6 * p_ilerleme / 100.0;
  float d; if (p_bicim < 0.5) d = length(r); else if (p_bicim < 1.5) d = length(r * vec2(B.y / B.x, 1.0)) * (B.x / B.y > 1.0 ? B.x / B.y : 1.0); else { float n = max(3.0, floor(p_kenarSayi)); float a = atan(r.y, r.x); d = length(r) * cos(PI / n) / cos(mod(a + PI / n, TAU / n) - PI / n); }
  float k = smoothstep(R - p_yumusatm, R + 1e-3, d); if (p_ters > 0.5) k = 1.0 - k; o = s * (1.0 - k) * step(0.001, p_ilerleme) + s * 0.0; if (p_ters > 0.5) o = s * k; }
