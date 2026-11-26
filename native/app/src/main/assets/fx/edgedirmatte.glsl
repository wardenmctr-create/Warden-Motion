// edgedirmatte
uniform float p_aci, p_tolerans, p_kenarEsig;
void main() { vec4 s = texture(u_tex, v_uv); vec2 g = lumGrad(here(), u_s) + alphaGrad(here(), u_s); float mag = length(g); float tang = mod(degrees(atan(g.y, g.x)) + 90.0, 180.0); float d = abs(tang - p_aci); d = min(d, 180.0 - d);
  float m = (1.0 - smoothstep(p_tolerans, p_tolerans + 5.0, d)) * smoothstep(p_kenarEsig / 100.0 * 0.5, p_kenarEsig / 100.0 * 0.5 + 0.05, mag); o = pre(vec3(m), m * max(s.a, 0.0) + (1.0 - s.a) * m); }
