// shadow_a
uniform float p_aci, p_mesafe, p_yayilma;
void main() { float a = radians(p_aci); vec2 off = vec2(cos(a), sin(a)) * p_mesafe * u_s; o = vec4(dilateA(here() - off, p_yayilma * u_s)); }
