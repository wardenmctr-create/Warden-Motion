// compass
uniform float p_buyukluk, p_stil, p_dvN; uniform float p_dv[8];
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - vec2(boxU().x * 0.38, -boxU().y * 0.38); float rot = p_dvN > 0.5 ? p_dv[0] : 0.0; q = rot2(rot) * q; float R = p_buyukluk * 0.5; float r = length(q) / R; float a = atan(q.x, -q.y);
  int N = p_stil < 2.5 ? 4 : 8; float sec = TAU / float(N); float la = mod(a + sec * 0.5, sec) - sec * 0.5; float spike = step(r, 1.0) * step(abs(la), (1.0 - r) * 0.35 * (p_stil < 0.5 ? 0.6 : 1.0)); bool north = abs(a) < sec * 0.5;
  vec4 col = vec4(0.0); col = overPre(vec4(0.1, 0.12, 0.2, 1.0) * step(r, 1.05) * 0.6, col); if (p_stil > 0.5) col = overPre(vec4(0.9, 0.85, 0.7, 1.0) * (1.0 - smoothstep(0.0, 0.04, abs(r - 1.0))), col);
  col = overPre(vec4(north ? vec3(0.9, 0.15, 0.15) : vec3(0.95), 1.0) * spike, col); o = overPre(col, s); }
