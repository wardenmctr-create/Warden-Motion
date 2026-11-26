// offsetfamily
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_ofsetSayi, p_aralik, p_kose, p_kesisimiTemi;
// Kaynak (ya da katman) silüetinin dışına eşit aralıklı paralel konturlar; yuvarlak köşe = öklid, keskin = sonsuz norm
float A(vec2 px) { return p_kaynakOn > 0.5 ? texture(s_kaynak, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (A(p) > 0.5) { o = s; return; } float G = p_aralik * u_s; float M = G * min(p_ofsetSayi, 64.0) + G; float d = 1e5;
  for (int i = 0; i < 24; i++) { float a = float(i) / 24.0 * TAU; vec2 dd = vec2(cos(a), sin(a)); if (p_kose > 0.5) dd /= max(abs(dd.x), abs(dd.y)); for (int k = 1; k <= 40; k++) { float r = float(k) / 40.0 * M; if (A(p + dd * r) > 0.5) { d = min(d, r * (p_kose > 0.5 ? 1.0 : 1.0)); break; } } }
  if (d > M - G * 0.5) { o = s; return; } float f = d / G; float line = 1.0 - smoothstep(0.06, 0.06 + 1.5 * u_s / G, abs(f - floor(f + 0.5))); line *= step(0.5, f);
  o = overPre(vec4(0.2, 0.55, 1.0, 1.0) * line, s); }
