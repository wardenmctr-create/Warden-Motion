// slant
uniform float p_egimAcis, p_yon, p_golge, p_golgeMesa; uniform vec2 p_dayanak; uniform vec3 c_golgeReng;
vec4 at(vec2 q) { vec2 r = q - p_dayanak; float t = tan(radians(clamp(p_egimAcis, -85.0, 85.0))); vec2 s = p_yon < 0.5 ? vec2(r.x - t * r.y, r.y) : vec2(r.x, r.y - t * r.x); return texU(p_dayanak + s); }
void main() {
  vec2 q = toUnit(here()); vec4 c = at(q);
  if (p_golge > 0.5) { float sa = at(q - vec2(p_golgeMesa) * 0.7071).a; c = overPre(c, vec4(c_golgeReng, 1.0) * sa * 0.85); }
  o = c;
}
