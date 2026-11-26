// mirrorrepeat
INCLUDE(_rep)
uniform float p_eksen, p_eksenAcis, p_mesafe, p_kopyaOpak, p_orijinalGost; uniform vec2 p_aynaCizg;
void main() {
  vec2 q = toUnit(here()); float a = p_eksen < 0.5 ? 90.0 : p_eksen < 1.5 ? 0.0 : p_eksenAcis + 90.0; vec2 d = vec2(cos(radians(a)), sin(radians(a))); vec2 n = vec2(-d.y, d.x);
  vec2 L = p_aynaCizg + n * (p_mesafe * 0.5); float s = dot(q - L, n); vec2 m = q - 2.0 * s * n;
  vec4 copy = repC(texU(repL(m, 1.0)), 1.0) * p_kopyaOpak / 100.0; vec4 orig = p_orijinalGost > 0.5 ? texU(q) : vec4(0.0); o = rov(orig, copy);
}
