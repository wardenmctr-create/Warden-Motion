// shear
uniform float p_yatayEgim, p_dikeyEgim, p_kenarKirp; uniform vec2 p_dayanak;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_dayanak;
  float tx = tan(radians(clamp(p_yatayEgim, -85.0, 85.0))), ty = tan(radians(clamp(p_dikeyEgim, -85.0, 85.0)));
  vec2 s = vec2(r.x - tx * r.y, r.y - ty * r.x) / max(0.05, 1.0 - tx * ty);
  s = vec2(r.x - tx * (r.y - ty * r.x), r.y - ty * r.x);
  vec4 c = texU(p_dayanak + s);
  if (p_kenarKirp > 0.5) { vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) c = vec4(0.0); }
  o = c;
}
