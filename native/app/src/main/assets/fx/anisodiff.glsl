// anisodiff
uniform float p_yineleme, p_kenarIlet, p_adim;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float k = p_kenarIlet / 100.0 * 0.3 + 0.01; int R = int(clamp(p_yineleme / 3.0, 1.0, 8.0)); vec3 acc = c; float ws = 1.0;
  for (int r = 1; r <= 8; r++) { if (r > R) break; for (int i = 0; i < 8; i++) { float a = float(i) * 0.785 + float(r) * 0.3; vec3 n = unpre(texPx(here() + vec2(cos(a), sin(a)) * float(r) * u_s)); float d = length(n - c); float w = exp(-(d * d) / (k * k)) * p_adim / 0.24; acc += n * w; ws += w; } }
  o = pre(acc / ws, s.a); }
