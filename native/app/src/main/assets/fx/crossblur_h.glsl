// crossblur_h
uniform float p_yatayYari, p_bagla, p_kenarUzat;
void main() { o = gauss1(here(), vec2(1.0, 0.0), p_yatayYari * u_s * 0.5, p_kenarUzat > 0.5 ? 3.0 : 0.0); }
