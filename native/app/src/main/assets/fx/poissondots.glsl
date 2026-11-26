// poissondots
uniform float p_enAzUzak, p_azamiNokt, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = max(p_enAzUzak, 1.0) * 0.7071; vec2 g = floor(q / cs); float m = 0.0; float dens = clamp(p_azamiNokt * cs * cs / max(boxU().x * boxU().y, 1.0), 0.0, 1.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g + vec2(i, j); vec2 p = (id + 0.15 + 0.7 * hash2(id + seedf(p_tohum))) * cs; if (hash1(id + 9.0 + seedf(p_tohum)) > dens) continue; m = max(m, 1.0 - smoothstep(cs * 0.12, cs * 0.18, length(q - p))); }
  o = overPre(vec4(1.0) * m, s); }
