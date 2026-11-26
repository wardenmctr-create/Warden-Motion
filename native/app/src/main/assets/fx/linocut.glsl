// linocut
INCLUDE(_mat)
uniform float p_oyukGeni, p_tonEsig; uniform vec3 c_murekkep;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float L = luma(unpre(s)); vec2 g = lumGrad(here(), 2.0 * u_s); float ang = length(g) > 0.01 ? atan(g.y, g.x) : 0.785;
  vec2 r = rot2(-degrees(ang) - 90.0) * q; float W = max(p_oyukGeni, 0.5); float gouge = abs(fract(r.y / (W * 2.5) + pnoise(q * 0.03) * 0.3) - 0.5) * 2.0;
  float ink = step(L, p_tonEsig / 100.0 + (gouge - 0.5) * 0.35); vec3 paper = matSample(1, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb; ink *= 0.85 + 0.15 * vnoise(q * 0.5);
  o = pre(mix(paper, c_murekkep, ink), s.a); }
