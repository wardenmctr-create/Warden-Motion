// floorshadow
uniform vec2 p_temasNokt; uniform float p_zeminEgim, p_yon, p_uzunluk, p_opaklik, p_yakinYumu, p_uzakYumu, p_uzakSolm; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 C = p_temasNokt; float ang = radians(p_yon); vec2 dir = vec2(cos(ang), sin(ang)); float ls = p_uzunluk / 100.0; float flat_ = cos(radians(p_zeminEgim));
  // zemindeki nokta → katmandaki karşılığı: temas çizgisinden uzaklık, gölge yönünde ölçeklenir
  vec2 d = q - C; float along = dot(d, dir); float side = dot(d, vec2(-dir.y, dir.x)); if (along < 0.0) { o = s; return; }
  float hgt = along / max(ls * flat_ + 0.05, 0.05); vec2 src = C + vec2(side, -hgt); float t = clamp(hgt / max(boxU().y, 1.0), 0.0, 1.0); float blur = mix(p_yakinYumu, p_uzakYumu, t) * u_s; float a = 0.0;
  for (int i = 0; i < 8; i++) { float an = float(i) * 0.785; a += texU(src + vec2(cos(an), sin(an)) / u_s * blur).a; } a /= 8.0;
  float sh = a * p_opaklik / 100.0 * (1.0 - t * p_uzakSolm / 100.0); o = overPre(s, vec4(c_renk, 1.0) * sh); }
