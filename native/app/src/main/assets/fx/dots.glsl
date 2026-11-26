// dots
uniform float p_noktaBoyu, p_noktaAral, p_faz, p_dizilim, p_boyutRast; uniform vec2 p_ofset; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 p = toUnit(here()) + p_ofset / 100.0 * boxU(); float sp = max(p_noktaAral, 1.0); vec2 c; vec2 id;
  if (p_dizilim > 0.5) { vec4 h = hexGrid(p, sp); c = h.xy; id = h.zw; } else { id = floor(p / sp); c = (id + 0.5) * sp; }
  float r = p_noktaBoyu * 0.5 * (1.0 + (hash1(id) - 0.5) * 2.0 * p_boyutRast / 100.0) * (0.85 + 0.15 * sin(p_faz / 100.0 * TAU + id.x * 0.7));
  float k = 1.0 - smoothstep(r - 0.7 / u_s, r + 0.7 / u_s, length(p - c));
  o = genOver(mix(vec4(c_renk2, 1.0), vec4(c_renk1, 1.0), k));
}
