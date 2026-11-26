// routewindow
uniform sampler2D s_hedef; uniform vec4 p_dv4[16]; float dvAt(int i) { return i < 0 || i >= 64 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform float p_hedefOn, p_dvN, p_pencereGeni, p_ilerleme, p_iziKaliTut;
// Pencere rota boyunca ilerler (motor: rota şeklinin noktaları), içinde hedef görünür; iz açık kalabilir
vec2 P(float u) { int N = p_dvN > 1.5 ? int(p_dvN / 2.0) : 0; if (N < 2) { float a = u * 6.2832; return vec2(cos(a) * boxU().x * 0.3 * u, sin(a) * boxU().y * 0.3 * u); } float f = u * float(N - 1); int i = int(floor(f)); return mix(vec2(dvAt(i * 2), dvAt(i * 2 + 1)), vec2(dvAt(min(i + 1, N - 1) * 2), dvAt(min(i + 1, N - 1) * 2 + 1)), fract(f)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = p_pencereGeni * 0.5; float pr = p_ilerleme / 100.0; float m = 0.0;
  if (p_iziKaliTut > 0.5) { for (int k = 0; k <= 40; k++) { float u = float(k) / 40.0 * pr; m = max(m, 1.0 - smoothstep(R - 1.0, R + 1.0, length(q - P(u)))); } } else m = 1.0 - smoothstep(R - 1.0, R + 1.0, length(q - P(pr)));
  vec4 t = p_hedefOn > 0.5 ? texture(s_hedef, boxUV(here())) : vec4(hueRotate(unpre(s), 140.0) * s.a, s.a); o = mix(s, t, m * step(0.001, pr)); }
