// guilloche
uniform vec2 p_merkez; uniform float p_yaricap, p_egriSayi, p_dalgaSayi, p_dalgaGucu, p_faz, p_cizgiKali, p_opaklik; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float r = length(q); float a = atan(q.y, q.x); float N = max(floor(p_egriSayi), 1.0); float acc = 0.0;
  for (int i = 0; i < 64; i++) { if (float(i) >= N) break; float fi = float(i); float ph = radians(p_faz) + fi / N * TAU / max(p_dalgaSayi, 1.0);
    float R = p_yaricap * (1.0 + p_dalgaGucu / 100.0 * 0.5 * sin(a * max(p_dalgaSayi, 1.0) + ph)) * (0.6 + 0.4 * fi / N); float d = abs(r - R);
    acc = max(acc, 1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8 / u_s, d)); }
  o = overPre(vec4(c_renk, 1.0) * acc * p_opaklik / 100.0, s); }
