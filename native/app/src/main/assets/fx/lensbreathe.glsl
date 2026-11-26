// lensbreathe
uniform float p_odak, p_solumaGucu; uniform vec2 p_merkez;
void main() { float k = 1.0 + p_solumaGucu / 100.0 * (p_odak - 50.0) / 50.0; o = texU((toUnit(here()) - p_merkez) / max(k, 0.05) + p_merkez); }
