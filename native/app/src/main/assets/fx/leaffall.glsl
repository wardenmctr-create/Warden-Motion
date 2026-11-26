// leaffall
uniform sampler2D s_ozelYaprGors; uniform float p_ozelYaprGorsOn;
uniform float p_yaprakTuru, p_yaprakSayi, p_buyukluk, p_buyuklukRast, p_dusmeHizi, p_sallanmaGeni, p_sallanmaHizi, p_donmeHizi, p_p3bDonu, p_derinlikDagi, p_dongu; uniform vec2 p_ruzgar; uniform vec3 c_yaprakRenk;
float leaf(vec2 p, float kind) { if (kind > 2.5 && kind < 3.5) { float a = atan(p.y, p.x); float r = length(p); return 1.0 - smoothstep(0.0, 0.08, r - 0.75 * (0.65 + 0.35 * abs(cos(a * 2.5)))); }
  if (kind > 1.5 && kind < 2.5) { float a = atan(p.x, -p.y); float r = length(p); return 1.0 - smoothstep(0.0, 0.08, r - 0.85 * (0.55 + 0.45 * abs(sin(a * 2.5))) ); }
  float w = kind > 0.5 ? 0.5 + 0.12 * sin(p.y * 18.0) : 0.45; return 1.0 - smoothstep(0.0, 0.08, length(vec2(p.x / w, p.y)) - 0.9) * 1.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec4 acc = vec4(0.0); float N = clamp(p_yaprakSayi, 0.0, 120.0);
  const vec3 AUT[4] = vec3[4](vec3(0.85, 0.35, 0.1), vec3(0.95, 0.6, 0.12), vec3(0.7, 0.18, 0.08), vec3(0.6, 0.45, 0.15));
  for (int i = 0; i < 120; i++) { if (float(i) >= N) break; float fi = float(i); vec2 h = hash2(vec2(fi, 3.3)); float z = mix(1.0, 0.4, hash1(vec2(fi, 7.0)) * p_derinlikDagi / 100.0);
    float sz = p_buyukluk * z * (1.0 + (h.y - 0.5) * p_buyuklukRast / 50.0); float H = B.y + sz * 4.0; float y = p_dongu > 0.5 ? mod(h.y * H + u_t * p_dusmeHizi * z, H) - H * 0.5 : h.y * H - H * 0.5 + u_t * p_dusmeHizi * z;
    float x = (h.x - 0.5) * B.x * 1.2 + p_ruzgar.x * u_t * z + sin(u_t * p_sallanmaHizi * TAU * z + fi) * p_sallanmaGeni; x = mod(x + B.x * 0.6, B.x * 1.2) - B.x * 0.6;
    vec2 l = q - vec2(x, y + p_ruzgar.y * u_t); float ang = u_t * p_donmeHizi * (h.x - 0.5) * 2.0 + fi * 40.0; l = rot2(-ang) * l / max(sz, 0.5);
    float flip = p_p3bDonu > 0.5 ? cos(u_t * 2.0 + fi) : 1.0; l.x /= max(abs(flip), 0.15); vec3 col = p_yaprakTuru < 0.5 || p_yaprakTuru > 1.5 && p_yaprakTuru < 2.5 ? AUT[int(mod(fi, 4.0))] : c_yaprakRenk;
    col *= c_yaprakRenk * (flip < 0.0 ? 0.75 : 1.0);
    float m; if (p_yaprakTuru > 3.5 && p_ozelYaprGorsOn > 0.5) { vec4 t = texture(s_ozelYaprGors, clamp(l * 0.5 + 0.5, 0.0, 1.0)); m = t.a; col = t.a > 0.0 ? t.rgb / t.a : col; } else m = leaf(l, p_yaprakTuru) * (1.0 - 0.2 * step(abs(l.x), 0.03) * step(abs(l.y), 0.8));
    acc = overPre(vec4(col * mix(0.7, 1.0, z), 1.0) * m, acc); }
  o = overPre(acc, s); }
