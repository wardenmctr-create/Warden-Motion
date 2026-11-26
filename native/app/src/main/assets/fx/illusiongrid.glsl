// illusiongrid
uniform float p_frekans, p_kayma, p_kontrast;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) * p_frekans; float row = floor(q.y); float x = q.x + mod(row, 2.0) * p_kayma / 100.0 + sin(row * 0.5) * p_kayma / 200.0; float sq = step(0.5, fract(x * 0.5));
  float mortar = 1.0 - smoothstep(0.03, 0.06, abs(fract(q.y) - 0.0)); vec3 c = mix(vec3(0.5 - p_kontrast / 140.0), vec3(0.5 + p_kontrast / 140.0), sq); c = mix(c, vec3(0.5), mortar); o = pre(c, s.a); }
