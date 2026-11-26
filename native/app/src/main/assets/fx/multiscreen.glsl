// multiscreen
INCLUDE(_chart)
uniform float p_ekran, p_duzen, p_cercevePayi, p_ekranNuma;
// Kompozisyon ekranlara bölünür (yatay, dikey ya da ızgara); ekranlar arası çerçeve payı içeriği gerçek koordinatta keser; isteğe bağlı numara
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float N = max(floor(p_ekran), 1.0); vec2 grid = p_duzen < 0.5 ? vec2(ceil(sqrt(N)), ceil(N / ceil(sqrt(N)))) : (p_duzen < 1.5 ? vec2(N, 1.0) : vec2(1.0, N));
  vec2 id = floor(b * grid); vec2 f = fract(b * grid); float idx = id.y * grid.x + id.x; vec2 g = p_cercevePayi * u_s / u_box.zw * grid * 0.5;
  if (idx >= N || any(lessThan(f, g)) || any(greaterThan(f, 1.0 - g))) { o = vec4(0.03, 0.03, 0.04, 1.0); return; } vec4 res = s;
  if (p_ekranNuma > 0.5) { vec2 lp = (f - vec2(0.1, 0.12)) / vec2(0.06, 0.08) / grid.yx * grid.y; res = overPre(vec4(1.0, 0.85, 0.3, 1.0) * numAt((f - vec2(0.12, 0.14)) * vec2(grid.x / grid.y, 1.0) / 0.06, idx + 1.0), res); } o = res; }
