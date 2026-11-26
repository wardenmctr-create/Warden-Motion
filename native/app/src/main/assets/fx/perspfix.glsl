// perspfix
uniform sampler2D s_anl; uniform float p_anlOn, p_duzeltme, p_otomatikKirp;
void main() { if (p_anlOn < 0.5) { o = texture(u_tex, v_uv); return; } float a = (texture(s_anl, vec2(0.25, 0.5)).r - 0.5) * 2.0, b = (texture(s_anl, vec2(0.75, 0.5)).r - 0.5) * 2.0; vec2 bb = boxUV(here()); float k = p_duzeltme / 100.0;
  float y = bb.y - 0.5; vec2 src = vec2(bb.x + (a + b * (bb.x - 0.5)) * y * k * (boxU().y / boxU().x), bb.y); if (p_otomatikKirp > 0.5) { float z = 1.0 + abs(b) * k * 0.5 + abs(a) * k * 0.5; src = (src - 0.5) / z + 0.5; }
  o = any(lessThan(src, vec2(0.0))) || any(greaterThan(src, vec2(1.0))) ? vec4(0.0) : texPx(boxPx(src)); }
