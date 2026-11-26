// phasescope
uniform sampler2D s_anl; uniform float p_anlOn; uniform vec3 c_renk;
void main() { vec2 b = boxUV(here()); vec4 bg = vec4(0.03, 0.05, 0.1, 0.9); vec2 q = b - 0.5; float axes = 1.0 - smoothstep(0.0, 0.003, min(abs(q.x), abs(q.y))); float diag = 1.0 - smoothstep(0.0, 0.003, min(abs(q.x - q.y), abs(q.x + q.y)));
  vec4 c = overPre(vec4(0.3, 0.35, 0.45, 1.0) * max(axes, diag * 0.6) * 0.6, bg); float g = p_anlOn > 0.5 ? texture(s_anl, b).a : exp(-dot(q * vec2(6.0, 2.5), q * vec2(6.0, 2.5)) * 8.0) * 0.6; o = overPre(vec4(c_renk, 1.0) * g, c); }
