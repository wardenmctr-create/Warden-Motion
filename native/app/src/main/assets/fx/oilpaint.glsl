// oilpaint
uniform float p_size; uniform float p_shine;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float r = p_size * u_s; vec3 m[4]; vec3 v2[4]; for (int k = 0; k < 4; k++) { m[k] = vec3(0.0); v2[k] = vec3(0.0); }
  for (int y = -3; y <= 3; y++) for (int x = -3; x <= 3; x++) { vec3 c = unpre(tex(v_uv + vec2(x, y) * r / 3.0 / u_res)); int q = (x <= 0 ? 0 : 1) + (y <= 0 ? 0 : 2); m[q] += c; v2[q] += c * c; }
  float best = 1e9; vec3 res = vec3(0.0);
  for (int k = 0; k < 4; k++) { vec3 mu = m[k] / 16.0; vec3 va = abs(v2[k] / 16.0 - mu * mu); float sv = va.r + va.g + va.b; if (sv < best) { best = sv; res = mu; } }
  float l = luma(res); res += (fract(l * 7.0) < 0.1 ? 0.05 : 0.0) * p_shine / 100.0; o = pre(clamp(res, 0.0, 1.0), s.a);
}
