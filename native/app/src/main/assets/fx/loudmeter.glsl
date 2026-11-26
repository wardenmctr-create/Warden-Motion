// loudmeter
uniform sampler2D s_anl; uniform float p_anlOn, p_olcuTuru, p_tepeTut;
void main() { vec2 b = boxUV(here()); vec4 bg = vec4(0.03, 0.05, 0.1, 0.9); float y = 1.0 - b.y; int k = int(p_olcuTuru + 0.5); int n = k == 4 ? 4 : 1; float col = floor(b.x * float(n)); int m = k == 4 ? int(col) : k;
  float v = p_anlOn > 0.5 ? texture(s_anl, vec2((float(m) + 0.5) / 4.0, 0.5)).r : 0.6 + 0.2 * sin(u_t * 3.0 + float(m)); float fx = fract(b.x * float(n));
  vec3 c = y < 0.7 ? vec3(0.2, 0.85, 0.4) : y < 0.9 ? vec3(1.0, 0.8, 0.2) : vec3(1.0, 0.25, 0.2); float bar = step(y, v) * step(0.15, fx) * step(fx, 0.85); float seg = step(0.2, fract(y * 30.0));
  o = overPre(vec4(c, 1.0) * bar * seg, bg); }
