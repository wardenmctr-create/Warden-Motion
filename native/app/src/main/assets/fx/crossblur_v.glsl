// crossblur_v
uniform float p_yatayYari, p_dikeyYari, p_bagla, p_kenarUzat;
void main() { o = gauss1(here(), vec2(0.0, 1.0), (p_bagla > 0.5 ? p_yatayYari : p_dikeyYari) * u_s * 0.5, p_kenarUzat > 0.5 ? 3.0 : 0.0); }
