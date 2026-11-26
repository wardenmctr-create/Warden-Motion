// waterfall
INCLUDE(_chart)
uniform vec3 c_arti, c_eksi; uniform float p_bosluk, p_toplamSutu;
// İlk sütun değişimler: her çubuk önceki birikimden yeni birikime; artı/eksi renkli; sonda toplam sütunu
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); int N = int(min(dR(), 40.0)); float slots = float(N) + (p_toplamSutu > 0.5 ? 1.0 : 0.0); float cum = 0.0, mn = 0.0, mx = 0.0;
  for (int r = 0; r < 40; r++) { if (r >= N) break; cum += dat(float(r), 0.0); mn = min(mn, cum); mx = max(mx, cum); } float rng = max(mx - mn, 1e-6); float x = (b.x - 0.05) / 0.9 * slots; int i = int(floor(x)); float f = fract(x);
  float gap = p_bosluk / 200.0; vec4 res = s; float y0 = 0.9 - (0.0 - mn) / rng * 0.8; res = overPre(vec4(vec3(0.7), 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.w, abs(b.y - y0))), res);
  if (b.x < 0.05 || b.x > 0.95 || f < gap || f > 1.0 - gap) { o = res; return; } float a = 0.0, c2 = 0.0; cum = 0.0; vec3 col = c_arti;
  for (int r = 0; r < 40; r++) { if (r >= N) break; float v = dat(float(r), 0.0); if (r == i) { a = cum; c2 = cum + v; col = v >= 0.0 ? c_arti : c_eksi; } cum += v; }
  if (i == N && p_toplamSutu > 0.5) { a = 0.0; c2 = cum; col = vec3(0.3, 0.55, 1.0); } if (i > N || (i == N && p_toplamSutu < 0.5)) { o = res; return; }
  float ya = 0.9 - (a - mn) / rng * 0.8, yb = 0.9 - (c2 - mn) / rng * 0.8; o = (b.y >= min(ya, yb) && b.y <= max(ya, yb)) ? vec4(col, 1.0) : res; }
