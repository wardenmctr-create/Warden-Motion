// noise
uniform float p_miktar, p_grenBoyu, p_tur, p_kontrast, p_tohum, p_zamanaBagl, p_alfayiEtki, p_dondur, p_yenilenme, p_golgeYog, p_ortaYog, p_acikYog; uniform vec2 p_grenOran;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 gs = max(p_grenBoyu, 0.3) * max(p_grenOran, vec2(1.0)) / 100.0; vec2 g = floor(toUnit(here()) / gs);
  bool anim = p_zamanaBagl > 0.5 && p_dondur < 0.5; float tk = anim ? floor(u_t * 30.0 / max(p_yenilenme, 1.0)) : 0.0; float sd = seedf(p_tohum);
  vec3 n;
  if (p_tur < 0.5) n = vec3(hash1(g + sd + tk), hash1(g + sd + tk + 31.0), hash1(g + sd + tk + 67.0));
  else if (p_tur < 1.5) n = vec3(hash1(g + sd + tk));
  else if (p_tur < 2.5) n = vec3(0.5 + (vnoise(g * 0.7 + tk * 13.0) - 0.5) * 1.4);
  else if (p_tur < 3.5) n = vec3(vnoise(g * 0.35 + tk * 3.7 + sd));
  else n = vec3(hash1(floor(g / 4.0) + sd + tk));
  n = (n - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  vec3 c = unpre(s); float l = luma(c); float tone = (1.0 - smoothstep(0.0, 0.4, l)) * p_golgeYog + (1.0 - abs(l - 0.5) * 2.0) * p_ortaYog + smoothstep(0.6, 1.0, l) * p_acikYog;
  float tw = tone / max(1.0 - smoothstep(0.0, 0.4, l) + (1.0 - abs(l - 0.5) * 2.0) + smoothstep(0.6, 1.0, l), 1e-3) / 100.0;
  float k = p_miktar / 100.0 * tw; vec3 r = mix(c, p_tur > 1.5 && p_tur < 2.5 ? overlayB(c, n) : n, clamp(k, 0.0, 1.0));
  float a = p_alfayiEtki > 0.5 ? max(s.a, k * n.r) : s.a; o = pre(clamp(r, 0.0, 1.0), a);
}
