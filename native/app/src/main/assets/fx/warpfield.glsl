// warpfield
uniform vec2 p_hedefler; uniform float p_etkiYari;
void main() { vec2 q = toUnit(here()); float r = max(p_etkiYari, 1.0); float w = exp(-dot(q, q) / (r * r)); o = texU(q - p_hedefler * w); }
