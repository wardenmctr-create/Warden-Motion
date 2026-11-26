// goboshadow
uniform sampler2D s_gobo; uniform vec2 p_isik; uniform float p_goboOn, p_kaynakGeni, p_mesafe, p_golge;
// Gobo, ışığın "mesafe" kadar altındaki yatay düzlemde; ışından piksele ışın bu düzlemi kestiği yerde maske okunur. Kaynak genişliği boyunca 7 örnek → yumuşak çoklu bant
float gob(vec2 u) { if (p_goboOn > 0.5) return texture(s_gobo, u).a; return step(0.5, fract(u.x * 7.0)) * step(0.0, u.x) * step(u.x, 1.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float lit = 0.0; vec2 bu = boxU();
  for (int i = -3; i <= 3; i++) { vec2 L = p_isik + vec2(float(i) / 3.0 * p_kaynakGeni * 0.5, 0.0); vec2 d = q - L; if (d.y <= p_mesafe) { lit += 1.0; continue; }
    float xg = d.x * p_mesafe / d.y; vec2 u = vec2(xg / max(bu.x * 0.5, 1.0) + 0.5, 0.5); lit += 1.0 - gob(u); }
  lit /= 7.0; float sh = (1.0 - lit) * p_golge / 100.0; o = vec4(s.rgb * (1.0 - sh), s.a); }
