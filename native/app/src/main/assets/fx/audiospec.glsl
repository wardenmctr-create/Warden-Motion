// audiospec
GRADIENT(renkGeci)
uniform vec4 p_dv4[64]; float dvAt(int i) { return i < 0 || i >= 256 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform vec2 p_baslangi, p_bitis; uniform float p_dvN, p_altFrek, p_ustFrek, p_bantSayi, p_yuksekli, p_kalinlik, p_yumusatm, p_gosterim, p_ikiTara;
float band(int i, float N) { if (p_dvN > 0.5) return clamp(dvAt(i), 0.0, 1.0); float x = float(i) / N; return clamp(0.55 + 0.35 * sin(u_t * 5.0 + x * 13.0) * sin(u_t * 2.3 + x * 5.0) - x * 0.3, 0.0, 1.0); }
// Çubuklar Başlangıç → Bitiş çizgisi boyunca dizilir, çizgiye dik yükselir (katman birimi)
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = p_baslangi, d = p_bitis - A; float L = max(length(d), 1e-3); vec2 t1 = d / L, nrm = vec2(t1.y, -t1.x);
  float u = dot(q - A, t1) / L; float y = dot(q - A, nrm); if (u < 0.0 || u > 1.0) { o = s; return; }
  float N = clamp(floor(p_bantSayi), 2.0, 128.0); if (p_dvN > 0.5) N = min(N, p_dvN);
  float fi = u * N; int i = int(min(floor(fi), N - 1.0)); float H = p_yuksekli; float th = max(p_kalinlik, 0.3); float aa = 0.75 / u_s; float a = 0.0;
  float yy = p_ikiTara > 0.5 ? abs(y) : y;
  if (p_gosterim < 0.5) { float v = band(i, N) * H; float cw = fract(fi); float inBar = step(0.12, cw) * step(cw, 0.88); a = inBar * step(0.0, yy) * (1.0 - smoothstep(max(v, th * 0.5) - aa, max(v, th * 0.5) + aa, yy)); }
  else { float fl = clamp(fi - 0.5, 0.0, N - 1.0); int i0 = int(floor(fl)); float v = mix(band(i0, N), band(min(i0 + 1, int(N) - 1), N), smoothstep(0.0, 1.0, fract(fl))) * H;
    if (p_gosterim < 1.5) a = 1.0 - smoothstep(th * 0.5 - aa, th * 0.5 + aa, abs(yy - v));
    else { float cx = (floor(fi) + 0.5) / N; float dx = (u - cx) * L; float vv = band(i, N) * H; a = 1.0 - smoothstep(th - aa, th + aa, length(vec2(dx, yy - vv))); } }
  o = overPre(vec4(grad_renkGeci(u), 1.0) * a, s); }
