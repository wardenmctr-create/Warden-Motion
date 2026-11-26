// stencilprint
uniform float p_sablon, p_kopruGeni, p_kenarSizi, p_katmanMaskCika;
// Ton seviyeleri ayrı şablonlarla basılır; şablon içinde asılı kalan adacıklar için düzenli köprü şeritleri kâğıt rengi bırakır; mürekkep kenarı hafif taşar
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float N = clamp(floor(p_sablon), 1.0, 12.0); float bleed = p_kenarSizi * u_s; float l = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) l += lumAt(p + vec2(i, j) * bleed * 0.5); l /= 9.0; float lev = floor((1.0 - l) * N + 0.5) / N;
  vec3 paper = vec3(0.96, 0.94, 0.88); vec3 inkc = unpre(s) * 0.85; int layer = int(lev * N + 0.5);
  float bridge = step(fract((p.x + p.y * 0.35) / (48.0 * u_s)), p_kopruGeni * u_s / (48.0 * u_s)) * step(1.5, float(layer));
  vec3 c = mix(paper, inkc, lev * (1.0 - bridge)); if (p_katmanMaskCika > 0.5) { vec2 b = boxUV(p); float k = floor(b.x * N); c = vec3(step(abs(lev * N - k - 1.0), 0.5)); }
  c *= 0.97 + 0.03 * hash1(floor(p / max(u_s, 1.0))); o = pre(c, s.a); }
