// subpixeldither
uniform sampler2D s_palet; uniform float p_paletOn, p_kume, p_esik, p_karisim;
// Kaynak palet (palet katmanından 8 renk ya da 4 seviyeli kanal nicemleme); iki en yakın renk arasında seçilen küme deseniyle titreme
vec3 palC(int i) { return texture(s_palet, vec2((float(i) + 0.5) / 8.0, 0.5)).rgb; }
float pat(vec2 c) { if (p_kume < 0.5) return fract((c.x + c.y) / 4.0) ; if (p_kume < 1.5) return mod(c.x + c.y, 2.0) * 0.5 + 0.25; int x = int(mod(c.x, 4.0)), y = int(mod(c.y, 4.0)); float m[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0); return (m[y * 4 + x] + 0.5) / 16.0; }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); vec3 a, b2; float k;
  if (p_paletOn > 0.5) { float d1 = 9.0, d2 = 9.0; a = c; b2 = c; for (int i = 0; i < 8; i++) { vec3 pc = palC(i); float d = length(pc - c); if (d < d1) { d2 = d1; b2 = a; d1 = d; a = pc; } else if (d < d2) { d2 = d; b2 = pc; } } k = d1 / max(d1 + d2, 1e-4); }
  else { vec3 lo = floor(c * 3.0) / 3.0, hi = min(lo + 1.0 / 3.0, 1.0); a = lo; b2 = hi; k = luma((c - lo) * 3.0); }
  vec2 cell = floor(here() / max(u_s, 1.0)); vec3 d = k > pat(cell) + (p_esik - 50.0) / 100.0 ? b2 : a; if (p_paletOn > 0.5 && k > pat(cell) + (p_esik - 50.0) / 100.0) d = b2; else if (p_paletOn > 0.5) d = a;
  o = pre(mix(c, d, p_karisim / 100.0), s.a); }
