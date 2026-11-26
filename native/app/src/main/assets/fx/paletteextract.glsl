// paletteextract
INCLUDE(_chart)
uniform float p_renkSayi, p_siralama, p_seffafiDisl, p_yuzdeEtik;
// 12×12 örnek; renkler ton/parlaklık kutularına toplanır, en dolu N kutu palet kartında oranla gösterilir
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int N = int(clamp(p_renkSayi, 2.0, 32.0)); vec4 acc[32]; for (int i = 0; i < 32; i++) acc[i] = vec4(0.0);
  float tot = 0.0;
  for (int j = 0; j < 12; j++) for (int i = 0; i < 12; i++) { vec4 q = texPx(boxPx((vec2(i, j) + 0.5) / 12.0)); if (p_seffafiDisl > 0.5 && q.a < 0.5) continue; vec3 c = q.a > 0.0 ? unpre(q) : vec3(0.0); vec3 h = rgb2hsv(c);
    int bin = h.y < 0.18 ? int(clamp(h.z * 4.0, 0.0, 3.0)) : 4 + int(floor(h.x * 14.0)) * 2 + int(step(0.55, h.z)); bin = bin % 32; acc[bin] += vec4(c, 1.0); tot += 1.0; }
  // en dolu N kutuyu seç (seçim sırası: alan)
  float used[32]; for (int i = 0; i < 32; i++) used[i] = 0.0; vec4 pal[32]; float frac[32]; for (int i = 0; i < 32; i++) { pal[i] = vec4(0.0); frac[i] = 0.0; }
  for (int n = 0; n < 32; n++) { if (n >= N) break; float bc = 0.0; int bi = -1; for (int i = 0; i < 32; i++) if (used[i] < 0.5 && acc[i].w > bc) { bc = acc[i].w; bi = i; } if (bi < 0) break; used[bi] = 1.0; pal[n] = vec4(acc[bi].rgb / acc[bi].w, 1.0); frac[n] = acc[bi].w / max(tot, 1.0); }
  if (p_siralama > 0.5) for (int a = 0; a < 32; a++) for (int i = 0; i < 31; i++) { if (i + 1 >= N) break; float ka = p_siralama < 1.5 ? rgb2hsv(pal[i].rgb).x : luma(pal[i].rgb); float kb = p_siralama < 1.5 ? rgb2hsv(pal[i + 1].rgb).x : luma(pal[i + 1].rgb);
    if (pal[i + 1].a > 0.0 && ka > kb) { vec4 t = pal[i]; pal[i] = pal[i + 1]; pal[i + 1] = t; float f = frac[i]; frac[i] = frac[i + 1]; frac[i + 1] = f; } }
  // kart: kutunun alt %22'si
  if (b.y < 0.78 || b.y > 1.0 || b.x < 0.0 || b.x > 1.0) { o = s; return; } float x = 0.0; vec4 col = vec4(0.1, 0.1, 0.12, 1.0); float x0 = 0.0, fw = 0.0, pct = 0.0;
  for (int i = 0; i < 32; i++) { if (i >= N || pal[i].a <= 0.0) break; float w = frac[i]; if (b.x >= x && b.x < x + w) { col = pal[i]; x0 = x; fw = w; pct = w * 100.0; } x += w; }
  if (p_yuzdeEtik > 0.5 && fw > 0.06) { vec2 lp = vec2((b.x - x0 - fw * 0.5) / 0.03, (b.y - 0.89) / 0.04); float nm = numAt(lp, pct); col.rgb = mix(col.rgb, luma(col.rgb) > 0.5 ? vec3(0.0) : vec3(1.0), nm); }
  o = col; }
