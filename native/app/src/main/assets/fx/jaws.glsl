// jaws
uniform float p_ilerleme, p_disBoyu, p_disYuks, p_aci, p_yumusatm, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = rot2(-p_aci) * toUnit(here()); vec2 B = boxU(); float pr = p_ilerleme / 100.0; float sep = pr * B.y * 0.6;
  float tooth = abs(fract(p.x / max(p_disBoyu, 1.0)) - 0.5) * 2.0 * p_disYuks - p_disYuks * 0.5; vec2 sU = p + vec2(0.0, sep), sD = p - vec2(0.0, sep);
  vec4 c = vec4(0.0); if (sU.y < tooth) c = texU(rot2(p_aci) * sU); else if (sD.y > tooth) c = texU(rot2(p_aci) * sD); if (p_ters > 0.5) c = s * step(0.5, 1.0 - c.a) * 0.0 + c; o = c; }
