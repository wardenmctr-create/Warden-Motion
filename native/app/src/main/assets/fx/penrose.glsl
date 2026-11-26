// penrose
uniform float p_yineleme, p_karoOlce, p_karoAile; uniform vec3 c_palet;
// de Bruijn ızgara yöntemi: 5 yönlü kayık ızgaralar; komşu tam sayı katmanları karo türünü belirler
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) / max(p_karoOlce, 10.0) * 4.0; float k[5]; float sum = 0.0; float edge = 1e9;
  for (int i = 0; i < 5; i++) { float a = float(i) * TAU / 5.0; float v = dot(q, vec2(cos(a), sin(a))) + 0.2 + p_yineleme * 0.01; k[i] = floor(v); sum += k[i]; edge = min(edge, abs(fract(v) - 0.5)); }
  float t = mod(sum, 5.0); float thin = p_karoAile < 0.5 ? step(2.5, t) : step(1.5, mod(sum + k[0], 3.0)); vec3 c = mix(c_palet, mix(c_palet, vec3(1.0), 0.6), thin) * (0.85 + 0.15 * fract(sum * 0.37));
  c = mix(c, vec3(0.05), 1.0 - smoothstep(0.43, 0.47, edge)); o = pre(c, s.a); }
