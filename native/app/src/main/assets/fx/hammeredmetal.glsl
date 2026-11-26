// hammeredmetal
uniform float p_cukurCapi, p_derinlik, p_darbeOrtu, p_puruz;
// Çekiç izleri: Voronoi hücresi başına çukur (merkeze eğimli normal); kapsama oranı kadar hücre; pürüz ince gürültü; metal ışığı
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()) / max(p_cukurCapi, 1.0); vec2 id = floor(q); vec2 best = vec2(0.0); float bd = 9.0; vec2 bc = vec2(0.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(i, j); vec2 pt = c + hash2(c); float d = length(q - pt); if (d < bd) { bd = d; best = pt; bc = c; } }
  float on = step(hash1(bc + 7.0), p_darbeOrtu / 100.0); vec2 dv = (q - best); float r = length(dv); vec3 n = normalize(vec3(-dv * on * p_derinlik * 0.6 * smoothstep(0.7, 0.0, r), 1.0));
  n = normalize(n + vec3(vec2(hash1(floor(here())) - 0.5, hash1(floor(here()) + 3.0) - 0.5) * p_puruz / 100.0 * 0.3, 0.0)); vec3 L = normalize(vec3(-0.5, -0.6, 1.0));
  float dif = clamp(dot(n, L), 0.0, 1.0); float spec = pow(clamp(dot(reflect(-L, n), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 30.0); vec3 c = unpre(s) * (0.35 + 0.75 * dif) + spec * 0.6; o = pre(clamp(c, 0.0, 1.0), s.a); }
