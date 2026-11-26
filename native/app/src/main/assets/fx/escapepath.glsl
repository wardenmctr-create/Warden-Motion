// escapepath
uniform vec2 p_baslangi; uniform float p_yineleme, p_kacisSini, p_cizgi;
// c başlangıç noktası (kutu → karmaşık düzlem [−2,1]×[−1.5,1.5]); z ← z² + c yolunun noktaları ve çizgileri; arkada soluk Mandelbrot
vec2 toC(vec2 u) { vec2 b = u / boxU() + 0.5; return vec2(-2.0 + b.x * 3.0, (0.5 - b.y) * 3.0); }
vec2 toU(vec2 c) { vec2 b = vec2((c.x + 2.0) / 3.0, 0.5 - c.y / 3.0); return (b - 0.5) * boxU(); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 cp = toC(q); vec2 z = vec2(0.0); float it = 0.0; for (int i = 0; i < 48; i++) { z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + cp; if (dot(z, z) > 4.0) break; it += 1.0; }
  vec4 res = overPre(vec4(vec3(0.25, 0.35, 0.6) * (it >= 48.0 ? 0.6 : it / 48.0), 1.0) * 0.55, s); vec2 c = toC(p_baslangi); z = vec2(0.0); vec2 prev = toU(z); float d = 1e5, dd = 1e5; float esc = p_kacisSini * p_kacisSini;
  for (int i = 0; i < 200; i++) { if (float(i) >= p_yineleme) break; z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c; vec2 cur = toU(z); vec2 ab = cur - prev; float t = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); d = min(d, length(q - prev - ab * t)); dd = min(dd, length(q - cur)); prev = cur; if (dot(z, z) > esc) break; }
  float aa = 0.8 / u_s; res = overPre(vec4(1.0, 0.8, 0.3, 1.0) * (1.0 - smoothstep(p_cizgi * 0.5 - aa, p_cizgi * 0.5 + aa, d)) * 0.8, res); res = overPre(vec4(1.0) * (1.0 - smoothstep(p_cizgi * 1.2 - aa, p_cizgi * 1.2 + aa, dd)), res);
  o = overPre(vec4(1.0, 0.3, 0.3, 1.0) * (1.0 - smoothstep(p_cizgi * 1.8 - aa, p_cizgi * 1.8 + aa, length(q - p_baslangi))), res); }
