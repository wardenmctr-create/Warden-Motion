// audiowave
uniform vec4 p_dv4[64]; float dvAt(int i) { return i < 0 || i >= 256 ? 0.0 : p_dv4[i >> 2][i & 3]; }
uniform vec2 p_baslangi, p_bitis; uniform vec3 c_renk; uniform float p_dvN, p_yuksekli, p_ornekSayi, p_zamanPenc, p_cizgiKali, p_kanal, p_ciftYon;
float smp(float x) { x = clamp(x, 0.0, 1.0); if (p_dvN > 0.5) { float f = x * (p_dvN - 1.0); int i = int(floor(f)); return mix(dvAt(i), dvAt(min(i + 1, int(p_dvN) - 1)), fract(f)); }
  return sin(x * 40.0 + u_t * 9.0) * 0.5 * (0.6 + 0.4 * sin(x * 7.0 - u_t * 3.0)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = p_baslangi, d = p_bitis - A; float L = max(length(d), 1e-3); vec2 t1 = d / L, nrm = vec2(t1.y, -t1.x);
  float u = dot(q - A, t1) / L; float y = dot(q - A, nrm); if (u < 0.0 || u > 1.0) { o = s; return; }
  float H = p_yuksekli; float th = max(p_cizgiKali, 0.3); float aa = 0.75 / u_s; float v = clamp(smp(u), -1.0, 1.0) * H;
  float dU = 1.0 / max(L * u_s, 1.0); float slope = (smp(u + dU) - smp(u - dU)) * H / (2.0 * dU * L); float corr = sqrt(1.0 + slope * slope);
  float dd = p_ciftYon > 0.5 ? abs(abs(y) - abs(v)) : abs(y - v);
  float a = 1.0 - smoothstep(th * 0.5 - aa, th * 0.5 + aa, dd / corr);
  if (p_ciftYon > 0.5) a = max(a, (1.0 - step(abs(v), abs(y))) * 0.35);
  o = overPre(vec4(c_renk, 1.0) * a, s); }
