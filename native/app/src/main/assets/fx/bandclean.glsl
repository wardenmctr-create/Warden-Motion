// bandclean
uniform float p_yon, p_seritEsig, p_koruma;
float lineMean(vec2 px, vec2 dir) { float a = 0.0; for (int i = -16; i <= 16; i++) a += luma(unpre(texPx(px + dir * float(i) * boxU().x * u_s / 32.0))); return a / 33.0; }
float localMean(vec2 px, vec2 dir) { vec2 n = vec2(-dir.y, dir.x); float a = 0.0; for (int i = -3; i <= 3; i++) a += lineMean(px + n * float(i) * 2.0 * u_s, dir); return a / 7.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float corr = 0.0;
  if (p_yon < 0.5 || p_yon > 1.5) { vec2 d = vec2(1, 0); float st = lineMean(here(), d) - localMean(here(), d); corr += abs(st) < p_seritEsig / 100.0 ? st : 0.0; }
  if (p_yon > 0.5) { vec2 d = vec2(0, 1); float st = lineMean(here(), d) - localMean(here(), d); corr += abs(st) < p_seritEsig / 100.0 ? st : 0.0; }
  float det = smoothstep(0.05, 0.25, sobel(here(), u_s)) * p_koruma / 100.0; o = pre(clamp(c - corr * (1.0 - det), 0.0, 1.0), s.a); }
