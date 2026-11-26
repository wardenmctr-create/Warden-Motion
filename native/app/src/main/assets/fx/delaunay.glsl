// delaunay
uniform float p_nokta, p_baglantiKali, p_hareket;
vec2 pt(vec2 id, float cs) { vec2 h = hash2(id); if (p_hareket > 0.5) h = 0.5 + 0.4 * vec2(sin(u_t + h.x * 6.28), cos(u_t * 0.8 + h.y * 6.28)); return (id + h) * cs; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_nokta, 3.0)); vec2 g = floor(q / cs); float best = 1e9;
  vec2 P[9]; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) P[(j + 1) * 3 + i + 1] = pt(g + vec2(i, j), cs);
  for (int a = 0; a < 9; a++) for (int b = a + 1; b < 9; b++) { vec2 A = P[a], B = P[b]; if (length(A - B) > cs * 1.6) continue; vec2 m = (A + B) * 0.5; vec2 ab = B - A; float u = clamp(dot(q - A, ab) / dot(ab, ab), 0.0, 1.0); best = min(best, length(q - A - ab * u)); }
  float l = 1.0 - smoothstep(p_baglantiKali * 0.5, p_baglantiKali * 0.5 + 0.8 / u_s, best); float dots = 0.0; for (int i = 0; i < 9; i++) dots = max(dots, 1.0 - smoothstep(2.0, 3.0, length(q - P[i]))); o = overPre(vec4(0.4, 0.8, 1.0, 1.0) * max(l, dots), s); }
