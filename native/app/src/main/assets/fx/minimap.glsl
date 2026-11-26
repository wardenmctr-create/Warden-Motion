// minimap
uniform sampler2D s_kucukHariKayn; uniform float p_kucukHariKaynOn, p_dvN; uniform float p_dv[8]; uniform vec2 p_pencereBoyu; uniform vec3 c_kadrajReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 W = p_pencereBoyu; vec2 o0 = boxU() * 0.5 - W - 10.0; vec2 l = (q - o0) / W; if (any(lessThan(l, vec2(0.0))) || any(greaterThan(l, vec2(1.0)))) { o = s; return; }
  vec4 m = p_kucukHariKaynOn > 0.5 ? texture(s_kucukHariKayn, l) : texPx(boxPx(l)); vec4 col = overPre(m, vec4(0.05, 0.08, 0.15, 1.0)); vec4 fr = p_dvN >= 4.0 ? vec4(p_dv[0], p_dv[1], p_dv[2], p_dv[3]) : vec4(0.35, 0.35, 0.65, 0.65);
  vec2 px = W * 0.004 + 1.5 / W; float inX = step(fr.x - px.x, l.x) * step(l.x, fr.z + px.x) * step(fr.y - px.y, l.y) * step(l.y, fr.w + px.y); float inI = step(fr.x + px.x, l.x) * step(l.x, fr.z - px.x) * step(fr.y + px.y, l.y) * step(l.y, fr.w - px.y);
  col = overPre(vec4(c_kadrajReng, 1.0) * (inX - inI), col); float edge = step(min(min(l.x, 1.0 - l.x), min(l.y, 1.0 - l.y)), 0.01); o = overPre(vec4(1.0) * edge, col); }
