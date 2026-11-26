// cellauto
uniform sampler2D s_anl; uniform float p_anlOn;
void main() { vec4 s = texture(u_tex, v_uv); if (p_anlOn < 0.5) { o = s; return; } ivec2 n = textureSize(s_anl, 0); vec2 uv = (floor(boxUV(here()) * vec2(n)) + 0.5) / vec2(n); float g = texture(s_anl, uv).r;
  vec2 f = fract(boxUV(here()) * vec2(n)); float cell = g * step(0.06, min(f.x, f.y)); o = pre(mix(vec3(0.04, 0.06, 0.12), vec3(0.3, 0.9, 0.6), cell), s.a); }
