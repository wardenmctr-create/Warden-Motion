// multitimepanel
INCLUDE(_hist)
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_pencere, p_zamanNokt, p_bosluk;
// Pano: N pencere, her biri klibin farklı bir anı (motor: kare şeridi)
void main() { vec2 b = boxUV(here()); float N = clamp(floor(p_pencere), 2.0, 16.0); float n = histN(); float cols = ceil(sqrt(N)); float rows = ceil(N / cols); vec2 id = floor(b * vec2(cols, rows)); vec2 f = fract(b * vec2(cols, rows)); float idx = id.y * cols + id.x;
  float g = p_bosluk * u_s / u_box.z * cols; if (idx >= N || any(lessThan(f, vec2(g))) || any(greaterThan(f, vec2(1.0 - g)))) { o = vec4(0.0); return; } vec2 uv = (f - g) / (1.0 - 2.0 * g);
  o = n >= 1.0 ? hist(min(idx, n - 1.0), uv) : texPx(boxPx(uv)); }
