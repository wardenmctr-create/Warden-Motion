// hextile
uniform float p_karoBoyu, p_aci, p_aralik, p_ayna; uniform vec2 p_ofset; uniform vec3 c_boslukReng;
void main() {
  vec2 B = boxU(); vec2 q = rot2(-p_aci) * (toUnit(here()) + p_ofset / 100.0 * B);
  float s = max(p_karoBoyu, 4.0); vec4 h = hexGrid(q, s);
  vec2 g = (q - h.xy) / s; float hd = hexDist(g);
  float gap = p_aralik / s;
  if (hd > 0.5 - gap * 0.5) { o = vec4(c_boslukReng, 1.0); return; }
  vec2 f = g / (1.0 - gap) * vec2(1.0, B.x / B.y) + 0.5;
  if (p_ayna > 0.5 && mod(h.z + h.w, 2.0) > 0.5) f.x = 1.0 - f.x;
  o = texPx(boxPx(clamp(f, 0.0, 1.0)));
}
