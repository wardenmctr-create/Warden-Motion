// origami
INCLUDE(_mat)
uniform float p_katDuze, p_katSayi, p_katAcis, p_duzensiz, p_kagit, p_dokuGucu, p_katIziGucu, p_isikAcis, p_katlanmaIler;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); float N = max(p_katSayi, 1.0); float cs = max(B.x, B.y) / N; vec2 id; vec2 f; float tri;
  if (p_katDuze < 1.5) { vec2 g = q / cs; id = floor(g); f = fract(g); tri = p_katDuze < 0.5 ? step(f.x, f.y) : step(0.5, f.x) + step(0.5, f.y) * 2.0; }
  else { float a = atan(q.y, q.x); float r = length(q); id = vec2(floor(a / TAU * N * 2.0), floor(r / cs)); f = vec2(fract(a / TAU * N * 2.0), fract(r / cs)); tri = step(f.x, f.y); }
  vec2 h = hash2(id + tri * 7.3) - 0.5; vec3 n = normalize(vec3(h * tan(radians(p_katAcis)) * (1.0 + p_duzensiz / 50.0), 1.0)); n = mix(vec3(0.0, 0.0, 1.0), n, clamp(p_katlanmaIler / 100.0, 0.0, 1.0));
  vec3 L = normalize(vec3(cos(radians(p_isikAcis)), sin(radians(p_isikAcis)), 1.0)); float lit = 0.55 + 0.6 * max(dot(n, L), 0.0);
  int mid[6] = int[6](1, 2, 6, 3, 9, 10); int m = mid[int(clamp(p_kagit, 0.0, 5.0))]; vec3 paper = matSample(m, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(luma(matBase(m)), 0.1);
  vec4 src = texU((id + (p_katDuze < 1.5 ? 0.5 : 0.0)) * cs); vec3 col = src.a > 0.0 ? unpre(texU(q)) : vec3(1.0); col = mix(col, col * paper, p_dokuGucu / 100.0) * lit;
  float crease = 1.0 - smoothstep(0.0, 0.03, min(min(f.x, 1.0 - f.x), min(f.y, abs(f.x - f.y)))); col *= 1.0 - crease * p_katIziGucu / 100.0 * 0.3;
  o = pre(clamp(col, 0.0, 1.0), s.a); }
