// chanblur_h
uniform float p_kirmiziYari, p_yesilYari, p_maviYari, p_alfaYari, p_eksen, p_kenarUzat;
void main() { float on = p_eksen > 1.5 ? 0.0 : 1.0; float e = p_kenarUzat > 0.5 ? 3.0 : 0.0; vec2 d = vec2(1.0, 0.0);
  o = vec4(gauss1(here(), d, p_kirmiziYari * u_s * 0.5 * on, e).r, gauss1(here(), d, p_yesilYari * u_s * 0.5 * on, e).g, gauss1(here(), d, p_maviYari * u_s * 0.5 * on, e).b, gauss1(here(), d, p_alfaYari * u_s * 0.5 * on, e).a); }
