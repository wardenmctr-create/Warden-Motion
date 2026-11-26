// denoise
uniform float p_gurultuAzal, p_ayrintiKoru, p_renkGuru, p_mekansalYari, p_zamansalKare, p_hareketTela;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_mekansalYari * u_s, 0.7); float tol = mix(0.25, 0.03, p_ayrintiKoru / 100.0); vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 f = vec2(float(i), float(j)) / 3.0; vec4 x = texPx(here() + f * R); vec3 c = unpre(x); float w = exp(-dot(f, f)) * exp(-dot(c - c0, c - c0) / (tol * tol)); acc += x * w; ws += w; }
  vec4 b = acc / ws; vec3 bc = unpre(b); vec3 r = mix(c0, bc, p_gurultuAzal / 100.0); r = mix(r, vec3(luma(r)) + (bc - vec3(luma(bc))), p_renkGuru / 100.0 * 0.5); o = pre(clamp(r, 0.0, 1.0), s.a); }
