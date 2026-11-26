// 800 rehberi, bölüm 9: ses görselleştiricileri (motor projedeki sesi analiz edip s_anl verir)
//== spectrogram
uniform sampler2D s_anl; uniform float p_anlOn; uniform vec3 c_palet;
void main() { vec2 b = boxUV(here()); if (p_anlOn < 0.5) { float v = 0.5 + 0.5 * sin(b.x * 30.0 + u_t * 3.0) * (1.0 - b.y); o = vec4(mix(c_palet, vec3(1.0, 0.8, 0.2), v * (1.0 - b.y)), 1.0); return; }
  float g = texture(s_anl, b).r; vec3 c = g < 0.5 ? mix(c_palet, vec3(0.7, 0.1, 0.6), g * 2.0) : mix(vec3(0.7, 0.1, 0.6), vec3(1.0, 0.9, 0.3), g * 2.0 - 1.0); o = vec4(c, 1.0); }
//== phasescope
uniform sampler2D s_anl; uniform float p_anlOn; uniform vec3 c_renk;
void main() { vec2 b = boxUV(here()); vec4 bg = vec4(0.03, 0.05, 0.1, 0.9); vec2 q = b - 0.5; float axes = 1.0 - smoothstep(0.0, 0.003, min(abs(q.x), abs(q.y))); float diag = 1.0 - smoothstep(0.0, 0.003, min(abs(q.x - q.y), abs(q.x + q.y)));
  vec4 c = overPre(vec4(0.3, 0.35, 0.45, 1.0) * max(axes, diag * 0.6) * 0.6, bg); float g = p_anlOn > 0.5 ? texture(s_anl, b).a : exp(-dot(q * vec2(6.0, 2.5), q * vec2(6.0, 2.5)) * 8.0) * 0.6; o = overPre(vec4(c_renk, 1.0) * g, c); }
//== loudmeter
uniform sampler2D s_anl; uniform float p_anlOn, p_olcuTuru, p_tepeTut;
void main() { vec2 b = boxUV(here()); vec4 bg = vec4(0.03, 0.05, 0.1, 0.9); float y = 1.0 - b.y; int k = int(p_olcuTuru + 0.5); int n = k == 4 ? 4 : 1; float col = floor(b.x * float(n)); int m = k == 4 ? int(col) : k;
  float v = p_anlOn > 0.5 ? texture(s_anl, vec2((float(m) + 0.5) / 4.0, 0.5)).r : 0.6 + 0.2 * sin(u_t * 3.0 + float(m)); float fx = fract(b.x * float(n));
  vec3 c = y < 0.7 ? vec3(0.2, 0.85, 0.4) : y < 0.9 ? vec3(1.0, 0.8, 0.2) : vec3(1.0, 0.25, 0.2); float bar = step(y, v) * step(0.15, fx) * step(fx, 0.85); float seg = step(0.2, fract(y * 30.0));
  o = overPre(vec4(c, 1.0) * bar * seg, bg); }
