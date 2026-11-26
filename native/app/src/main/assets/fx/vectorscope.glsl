// vectorscope
uniform sampler2D s_anl; uniform float p_anlOn, p_renkUzay, p_olcek, p_referansHede;
void main() { vec2 b = boxUV(here()); vec2 q = (b - 0.5) * 2.0; float sc = p_olcek / 100.0; vec2 uv = q / sc * 0.5 + 0.5; vec4 bg = vec4(0.03, 0.04, 0.07, 0.9) * step(length(q), 1.0);
  vec4 h = all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0))) ? texture(s_anl, uv) : vec4(0.0); vec4 r = overPre(vec4(h.rgb / max(h.a, 1e-3), 1.0) * h.a, bg);
  float ring = 1.0 - smoothstep(0.0, 0.01, abs(length(q) - 0.98)); r = overPre(vec4(0.5, 0.5, 0.5, 1.0) * ring, r);
  if (p_referansHede > 0.5) { vec3 T[6] = vec3[6](vec3(1, 0, 0), vec3(1, 1, 0), vec3(0, 1, 0), vec3(0, 1, 1), vec3(0, 0, 1), vec3(1, 0, 1));
    for (int i = 0; i < 6; i++) { vec3 c = T[i] * 0.75; float y = luma(c); vec2 p = vec2((c.b - y) / (p_renkUzay > 0.5 ? 2.03 : 1.8556), -(c.r - y) / (p_renkUzay > 0.5 ? 1.14 : 1.5748)) * 2.0 * sc;
      vec2 d = abs(q - p); float bx = step(max(d.x, d.y), 0.05) * (1.0 - step(max(d.x, d.y), 0.04)); r = overPre(vec4(T[i], 1.0) * bx, r); } }
  o = r; }
