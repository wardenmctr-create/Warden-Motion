// flowerrosette
uniform float p_yaprak, p_aci, p_yaprakUzun; uniform vec3 c_palet;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = int(clamp(p_yaprak, 1.0, 300.0)); float best = 0.0; float c2 = 0.0;
  for (int i = 0; i < 300; i++) { if (i >= N) break; float fi = float(i); float a = radians(p_aci) * fi; float r = sqrt(fi) * p_yaprakUzun * 0.35; vec2 c = vec2(cos(a), sin(a)) * r; vec2 l = rot2(-degrees(a)) * (q - c);
    float m = 1.0 - smoothstep(0.9, 1.0, length(l / vec2(p_yaprakUzun * 0.5, p_yaprakUzun * 0.2))); if (m > best) { best = m; c2 = fi / float(N); } }
  vec3 col = mix(c_palet * 0.6, c_palet, c2) * (0.85 + 0.15 * best); o = overPre(vec4(col, 1.0) * best, s); }
