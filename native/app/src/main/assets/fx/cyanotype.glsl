// cyanotype
INCLUDE(_mat)
uniform float p_pozlama, p_maviYogu, p_kagitDoku;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float L = clamp(luma(unpre(s)) * p_pozlama / 100.0, 0.0, 1.0); vec3 prussian = vec3(0.04, 0.18, 0.43); vec3 paper = vec3(0.92, 0.94, 0.95);
  vec3 c = mix(prussian, paper, pow(L, 0.8)); c = mix(paper, c, p_maviYogu / 100.0 + 0.2); c *= mix(vec3(1.0), matSample(1, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.5, 0.0).rgb / max(luma(matBase(1)), 0.1), p_kagitDoku / 100.0); o = pre(clamp(c, 0.0, 1.0), s.a); }
