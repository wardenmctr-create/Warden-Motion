// noise
uniform float p_miktar, p_grenBoyu, p_tur, p_kontrast, p_tohum, p_zamanaBagl, p_alfayiEtki;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 g = floor(toUnit(here()) / max(p_grenBoyu, 0.3)); float tk = p_zamanaBagl > 0.5 ? floor(u_t * 24.0) : 0.0; float sd = seedf(p_tohum);
  vec3 n = p_tur < 0.5 ? vec3(hash1(g + sd + tk), hash1(g + sd + tk + 31.0), hash1(g + sd + tk + 67.0)) : vec3(hash1(g + sd + tk));
  if (p_tur > 1.5) n = vec3(0.5 + (vnoise(g * 0.7 + tk * 13.0) - 0.5) * 1.4);
  n = (n - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  vec3 c = unpre(s); vec3 r = mix(c, p_tur > 1.5 ? overlayB(c, n) : n, p_miktar / 100.0);
  float a = p_alfayiEtki > 0.5 ? max(s.a, p_miktar / 100.0 * n.r) : s.a;
  o = pre(clamp(r, 0.0, 1.0), a);
}
