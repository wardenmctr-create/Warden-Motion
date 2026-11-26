// median
uniform float p_yaricap, p_kanal, p_yineleme, p_kenarKoru;
void main() {
  // 3x3 (ölçekli) ortanca: 9 örnekten parlaklığa göre ortanca
  float r = max(p_yaricap * u_s * 0.6, 0.7); vec4 v[9]; float l[9]; int k = 0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec4 c = texPx(here() + vec2(float(i), float(j)) * r); v[k] = c; l[k] = p_kanal > 1.5 ? c.a : luma(unpre(c)) + c.a * 0.001; k++; }
  for (int a = 0; a < 5; a++) { int mi = a; for (int b = a + 1; b < 9; b++) if (l[b] < l[mi]) mi = b; float tl = l[a]; l[a] = l[mi]; l[mi] = tl; vec4 tv = v[a]; v[a] = v[mi]; v[mi] = tv; }
  vec4 m = v[4]; vec4 s = texture(u_tex, v_uv);
  if (p_kanal > 0.5 && p_kanal < 1.5) m = pre(unpre(s) * (luma(unpre(m)) / max(luma(unpre(s)), 1e-3)), s.a);
  float e = clamp(sobel(here(), 1.0), 0.0, 1.0) * p_kenarKoru / 100.0;
  o = mix(m, s, e * 0.7);
}
