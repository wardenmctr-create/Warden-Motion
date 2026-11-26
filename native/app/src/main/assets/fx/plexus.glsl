// plexus
uniform vec3 c_cizgi; uniform float p_nokta, p_bagMesa, p_azamiKoms, p_kalinlik;
// Her ızgara hücresinde bir zerre (yavaş gezinir); komşu hücrelerdeki zerreler bağ mesafesi içindeyse çizgiyle bağlanır
vec2 pt(vec2 c, float cell) { vec2 h = hash2(c); return (c + 0.5 + 0.38 * vec2(sin(u_t * 0.6 + h.x * 6.28), cos(u_t * 0.5 + h.y * 6.28))) * cell; }
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cell = sqrt(boxU().x * boxU().y / max(p_nokta, 2.0)); vec2 id = floor(q / cell); float lw = max(p_kalinlik, 0.2); float v = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 a = pt(id + vec2(i, j), cell); v = max(v, 1.0 - smoothstep(lw * 1.2, lw * 2.4, length(q - a)));
    int cnt = 0; for (int jj = -1; jj <= 1; jj++) for (int ii = -1; ii <= 1; ii++) { if (ii == 0 && jj == 0) continue; if (float(cnt) >= p_azamiKoms) break; vec2 b = pt(id + vec2(i + ii, j + jj), cell); float L = length(a - b);
      if (L > p_bagMesa) continue; cnt++; v = max(v, (1.0 - smoothstep(lw * 0.5, lw * 0.5 + 1.0 / u_s, seg(q, a, b))) * (1.0 - L / p_bagMesa)); } }
  o = overPre(vec4(c_cizgi, 1.0) * v, s); }
