// relight
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn;
uniform float p_yuzeyKayn, p_yukselti, p_parlakli, p_puruzlul, p_isikGucu, p_ortamIsig; uniform vec3 p_isikKonu, c_isikReng;
float hAt(vec2 px) { if (p_yuzeyKayn < 0.5) return luma(unpre(texPx(px))); if (p_yuzeyKayn < 1.5) return texPx(px).a; if (p_haritaKatmOn > 0.5) return luma(unpre(texture(s_haritaKatm, clamp(boxUV(px), 0.0, 1.0)))); return luma(unpre(texPx(px))); }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 n;
  if (p_yuzeyKayn > 1.5 && p_yuzeyKayn < 2.5 && p_haritaKatmOn > 0.5) n = normalize(unpre(texture(s_haritaKatm, clamp(boxUV(here()), 0.0, 1.0))) * 2.0 - 1.0);
  else { float e = 1.5 * u_s; float hx = hAt(here() + vec2(e, 0.0)) - hAt(here() - vec2(e, 0.0)); float hy = hAt(here() + vec2(0.0, e)) - hAt(here() - vec2(0.0, e)); n = normalize(vec3(-hx, -hy, 0.02 + (1.0 - p_yukselti / 100.0) * 0.5)); }
  vec3 P = vec3(toUnit(here()), 0.0); vec3 Lp = vec3(p_isikKonu.x, p_isikKonu.y, -p_isikKonu.z); vec3 L = normalize(Lp - P); vec3 V = vec3(0.0, 0.0, 1.0);
  float dif = max(dot(n, L), 0.0); float sp = pow(max(dot(reflect(-L, n), V), 0.0), mix(64.0, 4.0, p_puruzlul / 100.0)) * p_parlakli / 100.0;
  vec3 c = unpre(s) * (p_ortamIsig / 100.0 + dif * p_isikGucu / 100.0 * c_isikReng) + c_isikReng * sp; o = pre(clamp(c, 0.0, 1.0), s.a); }
