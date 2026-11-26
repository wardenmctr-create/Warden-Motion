// mosaic
uniform float p_tasGeni, p_tasYuks, p_derz, p_renkYont, p_kareTas; uniform vec3 c_derzReng;
void main() {
  vec2 cs = vec2(max(p_tasGeni, 1.0), max(p_kareTas > 0.5 ? p_tasGeni : p_tasYuks, 1.0)) * u_s;
  vec2 id = floor((here() - u_box.xy) / cs); vec2 c0 = u_box.xy + id * cs;
  vec4 c;
  if (p_renkYont > 0.5) c = texPx(c0 + cs * 0.5);
  else { c = vec4(0.0); for (int j = 0; j < 3; j++) for (int i = 0; i < 3; i++) c += texPx(c0 + cs * (vec2(float(i), float(j)) + 0.5) / 3.0); c /= 9.0; }
  vec2 f = (here() - c0); float g = p_derz * u_s * 0.5;
  float e = min(min(f.x, cs.x - f.x), min(f.y, cs.y - f.y));
  float gm = 1.0 - smoothstep(g - 0.7, g + 0.7, e);
  float a = texPx(here()).a;
  o = mix(c, vec4(c_derzReng, 1.0) * max(a, c.a), gm * step(0.01, max(a, c.a)));
}
