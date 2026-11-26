// floorreflect
uniform vec2 p_temasNokt; uniform float p_zeminEgim, p_uzunluk, p_opaklik, p_uzakSolm, p_bulanikl, p_dalgalan, p_orijinalGost; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 C = p_temasNokt; float dy = q.y - C.y; vec4 base = p_orijinalGost > 0.5 ? s : vec4(0.0); if (dy < 0.0) { o = base; return; }
  float sc = max(p_uzunluk / 100.0 * cos(radians(p_zeminEgim)) + 0.05, 0.05); float sy = C.y - dy / sc; float t = clamp(dy / (boxU().y * 0.5 * sc + 1.0), 0.0, 1.0);
  float wx = p_dalgalan > 0.0 ? sin(dy * 0.15 + u_t * 3.0) * p_dalgalan * 0.3 : 0.0; vec4 r = vec4(0.0); float bl = p_bulanikl * u_s * (0.3 + t);
  for (int i = 0; i < 6; i++) { r += texU(vec2(q.x + wx + (float(i) - 2.5) * bl / u_s * 0.4, sy)); } r /= 6.0; r.rgb *= c_renk;
  r *= p_opaklik / 100.0 * (1.0 - t * p_uzakSolm / 100.0); o = overPre(base, r); }
