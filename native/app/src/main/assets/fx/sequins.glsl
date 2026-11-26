// sequins
uniform float p_pulCapi, p_yonRast, p_parlakli;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float D = max(p_pulCapi, 1.0); vec2 g = q / D; g.x += mod(floor(g.y), 2.0) * 0.5; vec2 id = floor(g); vec2 f = fract(g) - 0.5; float r = length(f);
  vec3 c = unpre(texU((id + 0.5) * D)); vec2 tilt = (hash2(id) - 0.5) * p_yonRast / 50.0; float spec = pow(max(0.0, 1.0 - length(tilt + vec2(sin(u_t * 1.5 + id.x), cos(u_t + id.y)) * 0.3)), 6.0) * p_parlakli / 100.0;
  float m = 1.0 - smoothstep(0.45, 0.5, r); float hole = smoothstep(0.06, 0.1, r); vec3 col = c * (0.7 + 0.4 * (1.0 - r)) + spec; o = pre(clamp(mix(c * 0.4, col, m * hole), 0.0, 1.0), s.a); }
