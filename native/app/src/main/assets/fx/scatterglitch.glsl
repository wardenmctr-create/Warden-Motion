// scatterglitch
uniform float u_rot; uniform float p_yon, p_yonUzay, p_hiz, p_blokBoyu, p_boyutRast, p_yogunluk, p_dogumSikl, p_omur, p_azamiUzak, p_yayilim, p_savrulmaBici, p_isinlanmSikl, p_isinlanmAdim, p_kaymaIvme, p_karmaKaymOran,
  p_hareketSapm, p_donus, p_hareketBula, p_etkiBolg, p_etkiGeni, p_kaynakSeklKoru, p_kaynaktaKopuAlfa, p_kaynakTopa, p_rgbDagi, p_rgbKanaUzak, p_rgbYonu, p_parazit, p_blokOran, p_tohum;
// Kaynak blokları seçilen yönde dijital rüzgârla savrulur. Her blok tohumla kararlı: doğum anı, ömür, sapma ve Azami uzaklık içindeki kendi mesafesi (Yayılım).
// Işınlanma kesikli adımlarla, kayma sürekli (ivmeli) ilerler; koptuğu yerde saydam boşluk kalır ve toparlanma süresince kapanır.
vec2 cellSize() { float w = max(p_blokBoyu, 1.0); float r = max(p_blokOran, 0.1); return vec2(w * sqrt(r), w / sqrt(r)); }
float region(vec2 c, vec2 d) { if (p_etkiBolg < 0.5 || p_etkiBolg > 1.5) return 1.0; vec2 B = boxU() * 0.5; float ext = abs(d.x) * B.x + abs(d.y) * B.y; return step(ext * (1.0 - 2.0 * p_etkiGeni / 100.0), dot(c, d)); }
// blok kimliği → (yaş, uçuş mesafesi, sapma açısı, etkin)
vec4 blockState(vec2 id, vec2 dir) { float h0 = hash1(id + p_tohum * 0.71); if (h0 > p_yogunluk / 100.0) return vec4(-1.0); float rate = max(p_dogumSikl, 0.01) * 0.25;
  float per = 1.0 / rate; float ph = hash1(id * 1.3 + 7.0 + p_tohum) * per; float cyc = floor((u_t + ph) / per); float age = u_t + ph - cyc * per; float life = max(p_omur, 0.02);
  float h1v = hash1(id + cyc * 13.7 + p_tohum); if (h1v > 0.6 + p_yogunluk / 250.0) return vec4(-1.0);
  vec2 C = (id + 0.5) * cellSize(); if (region(C, dir) < 0.5) return vec4(-1.0);
  float maxD = p_azamiUzak * (1.0 - p_yayilim / 100.0 * hash1(id * 2.7 + cyc + p_tohum * 3.3)); float slide = p_savrulmaBici < 0.5 ? 0.0 : (p_savrulmaBici < 1.5 ? 1.0 : step(hash1(id + cyc * 5.1), p_karmaKaymOran / 100.0));
  float dTele = floor(age * max(p_isinlanmSikl, 0.01)) * p_isinlanmAdim; float dSlide = p_hiz * age + 0.5 * p_kaymaIvme * age * age; float d = clamp(mix(dTele, dSlide, slide), 0.0, maxD);
  float dev = (hash1(id * 4.1 + cyc) - 0.5) * 2.0 * radians(p_hareketSapm); return vec4(age, d, dev, age <= life ? 1.0 : 0.0); }
void main() { vec2 q = toUnit(here()); float ang = radians(p_yon) - (p_yonUzay < 0.5 ? radians(u_rot) : 0.0); vec2 dir = vec2(cos(ang), sin(ang)); vec2 cs = cellSize();
  // kaynak: koptuğu yer saydam (şekil koruma payına kadar), toparlanma süresinde kapanır
  vec2 sid = floor(q / cs); vec4 base = texU(q); vec4 st0 = blockState(sid, dir);
  if (p_kaynaktaKopuAlfa > 0.5 && st0.x >= 0.0 && hash1(sid * 9.1 + p_tohum) > p_kaynakSeklKoru / 100.0) { float life = max(p_omur, 0.02); float close = st0.x <= life ? 1.0 : 1.0 - clamp((st0.x - life) / max(p_kaynakTopa, 0.001), 0.0, 1.0); base *= 1.0 - close; }
  vec4 res = base; float Lmax = p_azamiUzak + max(cs.x, cs.y);
  // uçan bloklar: geriye doğru yol boyunca aday kaynak hücreleri
  for (int k = 0; k <= 48; k++) { float s = float(k) / 48.0 * Lmax; for (int sd = -1; sd <= 1; sd++) { vec2 dd = vec2(dir.x, dir.y); float a = float(sd) * radians(p_hareketSapm) * 0.5; dd = vec2(dd.x * cos(a) - dd.y * sin(a), dd.x * sin(a) + dd.y * cos(a));
      vec2 id = floor((q - dd * s) / cs); vec4 st = blockState(id, dir); if (st.w < 0.5) continue; float a2 = st.z; vec2 fd = vec2(dir.x * cos(a2) - dir.y * sin(a2), dir.x * sin(a2) + dir.y * cos(a2));
      vec2 C = (id + 0.5) * cs; float sz = 1.0 - p_boyutRast / 100.0 * hash1(id * 3.9 + p_tohum); vec2 P = C + fd * st.y; vec2 lq = q - P; float rot = radians(p_donus) * st.x; lq = mat2(cos(rot), sin(rot), -sin(rot), cos(rot)) * lq;
      if (abs(lq.x) > cs.x * 0.5 * sz || abs(lq.y) > cs.y * 0.5 * sz) continue; vec2 src = C + lq / sz; vec4 c = texU(src); if (c.a <= 0.01) continue;
      float fade = 1.0 - smoothstep(0.6, 1.0, st.x / max(p_omur, 0.02)) * 0.9 - smoothstep(0.85, 1.0, st.y / max(p_azamiUzak, 1.0)) * 0.6 * step(1e-3, p_azamiUzak);
      if (p_rgbDagi > 0.5) { float ra = radians(p_rgbYonu); vec2 ro = vec2(cos(ra), sin(ra)) * p_rgbKanaUzak; c = vec4(texU(src + ro).r, c.g, texU(src - ro).b, max(c.a, max(texU(src + ro).a, texU(src - ro).a))); }
      if (p_parazit > 0.0) { float nz = step(1.0 - p_parazit / 100.0 * 0.5, hash1(vec2(floor(lq.y / max(cs.y * 0.12, 0.5)), floor(u_t * 24.0)) + id)); c.rgb = mix(c.rgb, vec3(c.a), nz * 0.6); }
      res = overPre(c * clamp(fade, 0.0, 1.0), res); } }
  o = res; }
