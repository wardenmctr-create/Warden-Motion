// mosaicgrout
uniform float p_tasBoyu, p_derzDeri, p_isikYonu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float T = max(p_tasBoyu, 2.0); vec2 g = q / T; g += vec2(pnoise(g * 0.7), pnoise(g * 0.7 + 3.0)) * 0.15; vec2 id = floor(g); vec2 f = fract(g) - 0.5;
  vec3 c = unpre(texU((id + 0.5) * T)); float dEdge = 0.5 - max(abs(f.x), abs(f.y)); float grout = 1.0 - smoothstep(p_derzDeri / T * 0.05, p_derzDeri / T * 0.05 + 0.03, dEdge);
  vec2 L = vec2(cos(radians(p_isikYonu)), sin(radians(p_isikYonu))); float sh = dot(normalize(f + 1e-4), L) * smoothstep(0.15, 0.0, dEdge) * 0.25; c = mix(c * (1.0 + sh), vec3(0.75, 0.73, 0.7) * (0.8 - 0.2 * dot(L, vec2(0.0, 1.0))), grout); o = pre(clamp(c, 0.0, 1.0), s.a); }
