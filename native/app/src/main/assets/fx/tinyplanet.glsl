// tinyplanet
uniform vec2 p_merkez; uniform float p_donus, p_yakinlas, p_ufuk, p_tersGeze, p_kenarSarm;
void main() { vec2 r = (toUnit(here()) - p_merkez) / (min(boxU().x, boxU().y) * 0.5) / max(p_yakinlas / 100.0, 0.01); float d = length(r); float a = atan(r.x, -r.y) + radians(p_donus);
  float v = p_tersGeze > 0.5 ? d / 1.0 : 1.0 - atan(d * 1.2) / (PI * 0.5) * (1.0 + (p_ufuk - 50.0) / 100.0); if (p_tersGeze > 0.5) v = 1.0 - v; v = 1.0 - v;
  vec2 s = vec2(fract(a / TAU + 0.5), clamp(v, 0.0, 1.0)); if (p_kenarSarm < 0.5 && (d > 1.4)) { o = vec4(0.0); return; } o = texPx(boxPx(clamp(s, 0.001, 0.999))); }
