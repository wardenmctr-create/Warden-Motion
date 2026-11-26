// histogram2
uniform sampler2D s_anl; uniform float p_anlOn, p_kanal, p_kutuSayi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float bins = max(floor(p_kutuSayi), 16.0); float x = (floor(b.x * bins) + 0.5) / bins; vec4 h = texture(s_anl, vec2(x, 0.5)); float y = 1.0 - b.y;
  vec3 col = vec3(0.0); float a = 0.0; int k = int(p_kanal + 0.5);
  if (k == 0) { col = vec3(step(y, h.r), step(y, h.g), step(y, h.b)); a = max(col.r, max(col.g, col.b)); } else { float v = k == 1 ? h.a : k == 2 ? h.r : k == 3 ? h.g : k == 4 ? h.b : h.a; a = step(y, v); col = k == 2 ? vec3(1, 0.3, 0.3) : k == 3 ? vec3(0.3, 1, 0.3) : k == 4 ? vec3(0.3, 0.5, 1) : vec3(0.9); }
  vec4 bg = vec4(0.05, 0.07, 0.12, 0.85); o = overPre(vec4(col, 1.0) * a * 0.9, bg); }
