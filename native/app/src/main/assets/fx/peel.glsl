// peel
uniform vec2 p_baslangi; uniform float p_soyulma, p_kivrim;
void main() { float p = p_soyulma / 100.0; vec2 b = boxUV(here()); vec2 o0 = p_baslangi / 100.0; vec2 dir = normalize(vec2(0.5) - o0 + 1e-4); float d = dot(b - o0, dir); float line = p * 1.5; float r = 0.03 + p_kivrim / 100.0 * 0.1;
  if (d > line) { o = texture(u_tex, v_uv) * (1.0 - smoothstep(line + 0.06, line, d) * 0.3); return; } float back = line - d; if (back < r * PI) { vec2 src = b + dir * back * 2.0; vec4 c = texPx(boxPx(clamp(src, 0.0, 1.0))); o = vec4(vec3(0.9), 1.0) * c.a * (0.7 + 0.3 * cos(back / r)); return; } o = vec4(0.0); }
