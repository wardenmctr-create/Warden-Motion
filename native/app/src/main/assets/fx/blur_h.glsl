// blur_h
uniform float p_yaricap, p_boyutlar, p_kenarPiksTekr, p_alfayiBula, p_eksenBagla, p_kalite; uniform vec2 p_xyYari;
float rx() { return (p_xyYari.x > 0.0 || p_xyYari.y > 0.0) ? p_xyYari.x : p_yaricap; }
void main() { float sg = p_boyutlar > 1.5 ? 0.0 : rx() * u_s * 0.5; o = gauss1(here(), vec2(1.0, 0.0), sg, p_kenarPiksTekr > 0.5 ? 3.0 : 0.0); }
