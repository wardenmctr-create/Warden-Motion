// streamlines
uniform sampler2D s_vektorAlan; uniform float p_vektorAlanOn, p_cizgiAral, p_uzunluk, p_adim;
// Vektör alanı (kaynak RG ya da parlaklık eğiminin dikine) boyunca seyrek tohum noktalarının integral eğrileri → eşit aralıklı akış çizgileri (LIC)
vec2 F(vec2 px) { if (p_vektorAlanOn > 0.5) { vec2 r = texture(s_vektorAlan, boxUV(px)).rg * 2.0 - 1.0; return length(r) > 0.02 ? normalize(r) : vec2(1.0, 0.0); } vec2 g = lumGrad(px, 3.0); return length(g) > 1e-4 ? normalize(vec2(-g.y, g.x)) : normalize(vec2(1.0, 0.3)); }
float seed(vec2 px) { float G = max(p_cizgiAral * u_s, 2.0); vec2 c = floor(px / G); vec2 h = hash2(c); vec2 sp = (c + 0.2 + h * 0.6) * G; return 1.0 - smoothstep(0.6, 1.4, length(px - sp)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float st = max(p_adim * u_s, 0.5); int n = int(min(p_uzunluk * u_s / st, 48.0)); float v = seed(p); vec2 a = p, b = p;
  for (int k = 0; k < 48; k++) { if (k >= n) break; a += F(a) * st; b -= F(b) * st; v = max(v, max(seed(a), seed(b)) * (1.0 - float(k) / float(n) * 0.3)); }
  o = overPre(vec4(vec3(0.95), 1.0) * v, vec4(s.rgb * 0.55, s.a)); }
