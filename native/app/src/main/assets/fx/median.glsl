// median
uniform float p_rad;
void main() { vec4 s = texture(u_tex, v_uv); float r = p_rad * u_s; if (r < 0.5 || s.a <= 0.0) { o = s; return; }
  vec3 v[9]; int k = 0; for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) { v[k] = unpre(tex(v_uv + vec2(x, y) * r / u_res)); k++; }
  for (int i = 0; i < 9; i++) for (int j = 0; j < 8; j++) { if (j >= 8 - i) break; vec3 a = min(v[j], v[j + 1]), b = max(v[j], v[j + 1]); v[j] = a; v[j + 1] = b; }
  o = pre(v[4], s.a); }
