// rotsym
uniform vec2 p_merkez; uniform float p_sektor, p_simetri, p_kaynakSektGost;
// Tek sektör (0..2π/N) döndürülerek (ya da yansıtılarak) tüm daireye çoğaltılır
void main() { vec2 q = toUnit(here()) - p_merkez; float N = max(floor(p_sektor), 2.0); float a = atan(q.y, q.x); float W = 6.2832 / N; float k = floor(a / W); float f = a - k * W;
  if (p_simetri > 0.5 && mod(k, 2.0) > 0.5) f = W - f; vec2 src = vec2(cos(f), sin(f)) * length(q) + p_merkez; vec4 c = texU(src);
  if (p_kaynakSektGost > 0.5) { float e = min(abs(a), abs(a - W)) * length(q); c = mix(c, vec4(1.0, 0.8, 0.2, 1.0), (1.0 - smoothstep(0.5, 1.5, e * u_s)) * step(-0.01, a) * step(a, W + 0.01)); } o = c; }
