// drypastel
INCLUDE(_mat)
uniform float p_pastelCapi, p_basinc, p_kagitDisi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 g = lumGrad(here(), 2.0 * u_s); float ang = length(g) > 0.01 ? degrees(atan(g.y, g.x)) + 90.0 : 30.0; vec2 r = rot2(-ang) * q;
  vec2 cell = floor(r / vec2(p_pastelCapi * 2.5, p_pastelCapi * 0.6)); vec3 col = unpre(texU(rot2(ang) * ((cell + 0.5) * vec2(p_pastelCapi * 2.5, p_pastelCapi * 0.6))));
  float tooth = fbm01(q * 0.35, 3.0); float cov = smoothstep(1.0 - p_basinc / 100.0, 1.0 - p_basinc / 100.0 + 0.25, tooth * (1.0 - p_kagitDisi / 200.0) + vnoise(r * vec2(0.08, 1.2)) * 0.5);
  vec3 paper = vec3(0.93, 0.9, 0.84); o = pre(mix(paper, col, cov), s.a); }
