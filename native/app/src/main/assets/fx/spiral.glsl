// spiral
uniform float p_kopyaSayi, p_icYari, p_disYari, p_tur, p_olcekAdim, p_yolaDond; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 96.0));
  for (int i = 0; i < 96; i++) { if (i >= N) break; float t = float(i) / max(float(N) - 1.0, 1.0); float a = t * p_tur * TAU; float r = mix(p_icYari, p_disYari, t);
    vec2 c = p_merkez + vec2(cos(a), sin(a)) * r; float sc = max(0.3 * (1.0 + p_olcekAdim / 100.0 * float(i)), 0.01); vec2 l = q - c; if (p_yolaDond > 0.5) l = rot2(-degrees(a) - 90.0) * l; res = overPre(texU(l / sc), res); }
  o = res;
}
