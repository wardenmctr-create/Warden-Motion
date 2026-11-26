// dollyzoom
uniform float p_kameraUzak, p_odakUzak;
void main() { vec2 q = toUnit(here()); float r = length(q) / (length(boxU()) * 0.5); float k = p_odakUzak / 50.0; float bend = 1.0 + (k - 1.0) * r * r * 0.5; float sc = 800.0 / max(p_kameraUzak, 10.0) * k; o = texU(q / max(sc * bend, 0.05) * 1.0); }
