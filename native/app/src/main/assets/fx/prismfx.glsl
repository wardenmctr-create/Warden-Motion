// prismfx
uniform float p_yuzSayi, p_prizmaAcis, p_kirilmaIndi;
void main() { vec2 q = toUnit(here()); float N = max(floor(p_yuzSayi), 3.0); float a = atan(q.y, q.x); float id = floor((a / TAU + 0.5) * N); float ca = (id + 0.5) / N * TAU - PI;
  vec2 shift = vec2(cos(ca), sin(ca)) * length(boxU()) * 0.08 * (p_kirilmaIndi - 1.0) * sin(radians(p_prizmaAcis)) * 3.0; vec4 r = texU(q - shift * 1.06), g = texU(q - shift), b = texU(q - shift * 0.94);
  o = vec4(r.r, g.g, b.b, max(r.a, max(g.a, b.a))) * (0.9 + 0.1 * cos(a * N)); }
