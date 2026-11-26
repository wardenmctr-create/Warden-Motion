// timemosaic
INCLUDE(_hist)
uniform float p_satirSutu, p_zamanAral, p_etiketle, p_hucreBosl;
void main() { float g = clamp(floor(p_satirSutu), 1.0, 4.0); vec2 b = boxUV(here()); vec2 cell = floor(b * g); vec2 f = fract(b * g); float k = cell.y * g + cell.x;
  float gap = p_hucreBosl / 100.0 * 0.5; if (any(lessThan(f, vec2(gap))) || any(greaterThan(f, vec2(1.0 - gap)))) { o = vec4(0.0); return; }
  vec2 uv = u_box.xy / u_res + ((f - gap) / (1.0 - 2.0 * gap)) * u_box.zw / u_res; vec4 c = histN() > 0.0 ? hist(k, uv) : texture(u_tex, uv);
  if (p_etiketle > 0.5) { vec2 lp = (f - vec2(0.12, 0.88)) * 20.0; c = overPre(vec4(1.0) * (1.0 - smoothstep(0.6, 0.9, length(lp))) * step(0.5, mod(k + 1.0, 2.0) + 0.5), c); } o = c; }
