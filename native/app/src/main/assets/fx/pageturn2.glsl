// pageturn2
uniform float p_kivrim, p_ilerleme, p_golge;
void main() { float p = p_ilerleme / 100.0; vec2 b = boxUV(here()); float edge = 1.0 - p * 1.3; float r = 0.05 + p_kivrim / 100.0 * 0.15; float x = b.x + (1.0 - b.y) * 0.2 * p;
  if (x < edge) { o = texture(u_tex, v_uv) * (1.0 - smoothstep(edge - 0.08, edge, x) * p_golge / 100.0); return; } float d = x - edge;
  if (d < r * PI) { float ang = d / r; float bx = edge - sin(ang) * r; if (ang < PI * 0.5) { o = texPx(boxPx(vec2(edge + ang * r, b.y))) * (0.7 + 0.3 * cos(ang)); return; } vec4 back = vec4(vec3(0.92), 1.0) * texPx(boxPx(vec2(clamp(edge + ang * r, 0.0, 1.0), b.y))).a; o = back * (0.6 + 0.4 * -cos(ang)); return; }
  o = vec4(0.0); }
