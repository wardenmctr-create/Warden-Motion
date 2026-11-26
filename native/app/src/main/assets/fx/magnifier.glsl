// magnifier
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_yakinlas; uniform vec2 p_ornekMerk, p_pencere, p_pencereBoyu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 W = p_pencereBoyu * 0.5; vec2 l = (q - p_pencere) / W; if (any(greaterThan(abs(l), vec2(1.0)))) { o = s; return; }
  vec2 src = p_ornekMerk / 100.0 + l * W / boxU() / (p_yakinlas / 100.0); vec4 c = p_kaynakOn > 0.5 ? texture(s_kaynak, clamp(src, 0.0, 1.0)) : texPx(boxPx(src)); float edge = step(1.0 - 4.0 / max(W.x, 1.0), max(abs(l.x), abs(l.y)));
  o = overPre(vec4(1.0) * edge, overPre(c, vec4(0.0, 0.0, 0.0, 1.0))); }
