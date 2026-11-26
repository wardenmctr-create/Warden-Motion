// dustscratch
uniform float p_yaricap, p_esik, p_inceAyriKoru, p_kanal, p_zamanFilt;
void main() {
  vec4 s = texture(u_tex, v_uv); float r = max(p_yaricap * u_s * 0.6, 0.7); vec4 v[9]; float l[9]; int k = 0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec4 c = texPx(here() + vec2(float(i), float(j)) * r); v[k] = c; l[k] = luma(unpre(c)); k++; }
  for (int a = 0; a < 5; a++) { int mi = a; for (int b = a + 1; b < 9; b++) if (l[b] < l[mi]) mi = b; float tl = l[a]; l[a] = l[mi]; l[mi] = tl; vec4 tv = v[a]; v[a] = v[mi]; v[mi] = tv; }
  float diff = abs(luma(unpre(s)) - l[4]); float m = smoothstep(p_esik / 100.0 * 0.5, p_esik / 100.0 * 0.5 + 0.05, diff) * (1.0 - p_inceAyriKoru / 100.0 * 0.3);
  o = mix(s, v[4], m);
}
