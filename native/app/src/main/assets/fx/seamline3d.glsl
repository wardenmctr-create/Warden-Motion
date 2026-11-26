// seamline3d
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 c_renk; uniform float p_kaynak, p_kalinlik, p_yuzeyOfse;
// Dikiş: ön/arka yüz ile yan duvarın birleştiği kenar döngüsü (UV dikişi) ya da ortadan geçen kenar (seçili)
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); float side = 1.0 - smoothstep(0.4, 0.8, abs(n.z)); float d = p_kaynak < 0.5 ? abs(abs(p.z) - 10.0 + p_yuzeyOfse) * (side > 0.5 ? 1.0 : 99.0) : abs(p.z) * side + (1.0 - side) * abs(p.y);
  float line = 1.0 - smoothstep(p_kalinlik * 0.5, p_kalinlik * 0.5 + 0.8, d); return vec4(mix(c.rgb, c_renk, line), 1.0); }
void main() { o = render3d(vec3(0.0)); }
