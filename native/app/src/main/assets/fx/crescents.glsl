// crescents
uniform float p_cap, p_kesisimOran, p_aci;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()); float D = max(p_cap, 2.0); vec2 g = q / D; g.x += mod(floor(g.y), 2.0) * 0.5; vec2 f = fract(g) - 0.5; float r = 0.42;
  float a = 1.0 - smoothstep(r - 0.01, r + 0.01, length(f)); float b = 1.0 - smoothstep(r - 0.01, r + 0.01, length(f - vec2(r * (1.0 - p_kesisimOran / 100.0) * 1.2, 0.0))); float cr = a * (1.0 - b);
  o = pre(mix(vec3(0.07, 0.1, 0.22), vec3(0.95, 0.8, 0.3), cr), s.a); }
