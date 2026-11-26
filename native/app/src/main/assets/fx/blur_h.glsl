// blur_h
uniform float p_yaricap, p_boyutlar, p_kenarPiksTekr, p_alfayiBula;
void main() { float sg = p_boyutlar > 1.5 ? 0.0 : p_yaricap * u_s * 0.5; vec4 c = gauss1(here(), vec2(1.0, 0.0), sg, p_kenarPiksTekr > 0.5 ? 3.0 : 0.0); o = c; }
