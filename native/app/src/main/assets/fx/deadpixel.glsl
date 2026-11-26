// deadpixel
uniform sampler2D s_sinirlayMask; uniform float p_sinirlayMaskOn;
uniform float p_kusurTuru, p_sapmaEsig, p_kusurCapi, p_doldurma, p_ayrintiKoru, p_kusurlarIsar;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_kusurCapi, 1.0) * u_s + 1.0; vec3 v[8]; vec3 mean = vec3(0.0);
  for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; v[i] = unpre(texPx(here() + vec2(cos(a), sin(a)) * R)); mean += v[i] / 8.0; }
  // 8 komşunun ortancası (her kanal ayrı, seçmeli sıralama)
  vec3 med; for (int ch = 0; ch < 3; ch++) { float a[8]; for (int i = 0; i < 8; i++) a[i] = v[i][ch]; for (int i = 0; i < 5; i++) for (int j = i + 1; j < 8; j++) if (a[j] < a[i]) { float t = a[i]; a[i] = a[j]; a[j] = t; } med[ch] = (a[3] + a[4]) * 0.5; }
  float dev = luma(c0) - luma(med); float cd = length(c0 - med); float th = p_sapmaEsig / 100.0;
  bool bad = p_kusurTuru < 0.5 ? cd > th : p_kusurTuru < 1.5 ? dev > th : p_kusurTuru < 2.5 ? -dev > th : length((c0 - luma(c0)) - (med - luma(med))) > th;
  float spread = 0.0; for (int i = 0; i < 8; i++) spread = max(spread, length(v[i] - med)); if (spread > th * (1.0 + p_ayrintiKoru / 50.0)) bad = false;
  if (p_sinirlayMaskOn > 0.5 && texture(s_sinirlayMask, clamp(boxUV(here()), 0.0, 1.0)).a < 0.5) bad = false;
  if (!bad) { o = s; return; } if (p_kusurlarIsar > 0.5) { o = vec4(1.0, 0.0, 0.0, 1.0); return; }
  o = pre(p_doldurma < 0.5 ? med : p_doldurma < 1.5 ? mix(med, mean, 0.5) : mean, s.a); }
