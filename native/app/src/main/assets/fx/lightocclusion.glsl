// lightocclusion
uniform sampler2D s_engel; uniform vec2 p_isikKayn; uniform float p_engelOn, p_erisim, p_acisalOrne, p_kenarGeci;
// Işıktan piksele doğru 2B ışın yürütme; engel (kaynak katman ya da katmanın kendi alfası) kesişirse gölge; erişim mesafesiyle söner
float occ(vec2 px) { return p_engelOn > 0.5 ? texture(s_engel, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 L = p_isikKayn; vec2 d = q - L; float D = length(d); float steps = clamp(p_acisalOrne / 8.0, 8.0, 64.0); float vis = 1.0;
  for (int k = 1; k < 64; k++) { if (float(k) >= steps) break; vec2 pp = L + d * float(k) / steps; float o2 = occ(fromUnit(pp)); vis = min(vis, 1.0 - o2 * smoothstep(0.0, p_kenarGeci * 0.02 + 0.05, 1.0 - float(k) / steps)); }
  if (p_engelOn < 0.5 && s.a > 0.5) vis = 1.0; float fall = 1.0 - smoothstep(p_erisim * 0.6, p_erisim, D); float lit = vis * fall;
  vec3 c = s.a > 0.0 ? s.rgb * (0.35 + 0.65 * lit) : vec3(1.0, 0.95, 0.8) * lit * 0.35; o = vec4(c, max(s.a, lit * 0.35)); }
