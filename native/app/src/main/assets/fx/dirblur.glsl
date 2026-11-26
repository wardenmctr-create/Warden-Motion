// dirblur
uniform float p_uzunluk, p_aci, p_ornekSayi, p_kenarUzat;
void main() { float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)) * p_uzunluk * u_s * 0.5; o = lineAvg(here() - d, here() + d, int(clamp(p_ornekSayi, 4.0, 128.0)), p_kenarUzat > 0.5 ? 3.0 : 0.0); }
