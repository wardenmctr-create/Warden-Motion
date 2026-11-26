// waxcrayon
uniform float p_darbeCapi, p_bosluk, p_basinc;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 r = rot2(-35.0) * q; float W = max(p_darbeCapi, 1.0); float row = floor(r.y / W); vec2 sp = rot2(35.0) * vec2(floor(r.x / (W * 3.0)) * W * 3.0 + W * 1.5, row * W + W * 0.5);
  vec3 col = unpre(texU(sp)); float grain = vnoise(q * vec2(0.9, 0.25) * 2.0) * 0.6 + vnoise(q * 1.7) * 0.4; float wax = step(p_bosluk / 100.0 * 0.8, grain) * (0.75 + 0.25 * p_basinc / 100.0);
  vec3 paper = vec3(0.97, 0.96, 0.92); vec3 c = mix(paper, col * (0.9 + 0.2 * vnoise(r * vec2(0.05, 1.0))), wax); o = pre(c, s.a); }
