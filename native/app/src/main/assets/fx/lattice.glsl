// lattice
uniform float p_satirSutu, p_esneklik; uniform vec2 p_kafesNokt;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); float N = max(floor(p_satirSutu), 2.0); vec2 b = boxUV(here()); vec2 g = b * (N - 1.0); vec2 c = vec2((N - 1.0) * 0.5);
  float w = exp(-dot(g - c, g - c) / max(N * N * 0.08 * (0.3 + p_esneklik / 100.0), 0.01)); o = texU(q - p_kafesNokt * w); }
