// chanalpha
uniform float p_cikti, p_normaliz, p_kenarEsig, p_tersCevi;
// R, G, B kanalları ayrı mat: "Üç mat" kutuyu üç şeride böler (R | G | B), "Tek kanal" en baskın kanalın matını verir
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); vec2 b = boxUV(here()); vec3 m = c;
  if (p_normaliz > 0.5) { vec3 mx = vec3(1e-3); for (int j = 0; j < 8; j++) for (int i = 0; i < 8; i++) mx = max(mx, unpre(texPx(boxPx((vec2(i, j) + 0.5) / 8.0)))); m = c / mx; }
  m = smoothstep(vec3(p_kenarEsig / 100.0), vec3(p_kenarEsig / 100.0 + 0.05 + 1e-3), m) * (p_kenarEsig > 0.0 ? 1.0 : 0.0) + (p_kenarEsig > 0.0 ? vec3(0.0) : m); if (p_tersCevi > 0.5) m = 1.0 - m; m *= s.a;
  if (p_cikti < 0.5) { int k = int(clamp(floor(b.x * 3.0), 0.0, 2.0)); float v = k == 0 ? m.r : (k == 1 ? m.g : m.b); vec3 tint = k == 0 ? vec3(1.0, 0.3, 0.3) : (k == 1 ? vec3(0.3, 1.0, 0.4) : vec3(0.35, 0.55, 1.0)); o = vec4(mix(vec3(v), tint * v, 0.25), max(v, 0.0) > 0.0 ? 1.0 : s.a); }
  else { float v = max(m.r, max(m.g, m.b)); o = vec4(vec3(v), v); } }
