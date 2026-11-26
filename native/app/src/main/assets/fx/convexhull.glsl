// convexhull
uniform vec3 c_dolgu; uniform float p_gruplama, p_yumusakl, p_cikti;
// Dışbükey zarf: 32 yöndeki ışınlardan isabet alanların arasındaki en büyük açı boşluğu 180°'den küçükse nokta zarfın içindedir
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float L = p_gruplama < 0.5 ? length(u_res) : max(u_box.z, u_box.w) * 0.3; float st = max(L / 40.0, 1.0);
  float last = -1.0, first = -1.0, gap = 0.0;
  for (int i = 0; i < 32; i++) { float a = float(i) / 32.0 * TAU; vec2 d = vec2(cos(a), sin(a)); bool hit = s.a > 0.5;
    for (int k = 1; k <= 40; k++) { if (hit) break; float r = float(k) * st; if (r > L) break; vec2 q = p + d * r; if (q.x < 0.0 || q.y < 0.0 || q.x > u_res.x || q.y > u_res.y) break; if (texPx(q).a > 0.5) hit = true; }
    if (hit) { if (first < 0.0) first = float(i); if (last >= 0.0) gap = max(gap, float(i) - last); last = float(i); } }
  if (first >= 0.0) gap = max(gap, first + 32.0 - last); else gap = 32.0;
  float soft = max(p_yumusakl * u_s / max(L, 1.0) * 32.0, 0.35); float h = 1.0 - smoothstep(16.0 - soft, 16.0 + soft, gap); h = max(h, s.a);
  o = p_cikti < 0.5 ? vec4(vec3(h), h) : overPre(s, vec4(c_dolgu * h, h)); }
