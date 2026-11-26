// holefill
uniform vec3 c_tekRenk; uniform float p_enBuyuDeli, p_dolguAlfa, p_dolguReng;
// Saydam piksel: 16 yönde ışın; hepsi delik çapı içinde opak kenara çarparsa kapalı deliktir
void main() { vec4 s = texture(u_tex, v_uv); if (s.a > 0.5) { o = s; return; }
  float R = 2.0 * sqrt(max(p_enBuyuDeli, 1.0) / PI) * u_s; float st = max(R / 32.0, 1.0); vec2 p = here(); float hits = 0.0; vec4 near = vec4(0.0); float nd = 1e9;
  for (int i = 0; i < 16; i++) { float a = float(i) / 16.0 * TAU; vec2 d = vec2(cos(a), sin(a)); bool hit = false;
    for (int k = 1; k <= 32; k++) { float r = float(k) * st; if (r > R) break; vec4 q = texPx(p + d * r); if (q.a > 0.5) { hit = true; if (r < nd) { nd = r; near = q; } break; } }
    if (hit) hits += 1.0; else break; }
  if (hits < 16.0) { o = s; return; }
  vec3 col = p_dolguReng < 0.5 ? unpre(near) : c_tekRenk; float a = p_dolguAlfa / 100.0; o = overPre(s, vec4(col * a, a)); }
