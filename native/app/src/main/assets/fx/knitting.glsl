// knitting
uniform float p_ilmekBoyu, p_ipKali, p_orguTipi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float S = max(p_ilmekBoyu, 2.0); vec2 g = q / vec2(S, S * 0.8); vec2 id = floor(g); vec2 f = fract(g);
  vec3 c = unpre(texU((id + 0.5) * vec2(S, S * 0.8))); bool purl = p_orguTipi > 0.5 && p_orguTipi < 1.5 || (p_orguTipi > 1.5 && p_orguTipi < 2.5 && mod(id.x, 2.0) > 0.5);
  float side = f.x < 0.5 ? 1.0 : -1.0; vec2 lf = vec2(abs(f.x - 0.5) * 2.0, f.y); if (p_orguTipi > 2.5) lf.x = abs(fract(f.x + f.y * 0.5) - 0.5) * 2.0;
  float v = purl ? abs(sin(f.y * PI * 2.0)) : 1.0 - abs(lf.x - (1.0 - lf.y) * 0.6 - 0.2) / max(p_ipKali / S * 1.5, 0.05); v = clamp(v, 0.0, 1.0);
  float fiber = 0.85 + 0.15 * sin((f.x + f.y) * 40.0); o = pre(c * (0.45 + 0.55 * v) * fiber, s.a); }
