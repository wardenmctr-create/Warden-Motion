// paintdrip
uniform float p_akisHizi, p_viskozit, p_damlaYogu;
void main() { vec2 q = toUnit(here()); float colW = max(4.0, 12.0 * (1.0 - p_viskozit / 200.0)); float cx = floor(q.x / colW); float h = hash1(vec2(cx, 7.0)); vec4 s = texture(u_tex, v_uv);
  float len = (h < p_damlaYogu / 100.0) ? min(u_t * p_akisHizi * (0.5 + h), boxU().y) * (1.0 - p_viskozit / 150.0) : 0.0; vec4 best = s;
  for (int i = 1; i <= 16; i++) { float d = len * float(i) / 16.0; vec4 up = texU(vec2(q.x, q.y - d)); float wcol = 1.0 - smoothstep(colW * 0.25, colW * 0.45, abs(fract(q.x / colW) - 0.5) * colW * (1.0 + float(i) / 16.0));
    if (up.a > 0.5 && best.a < 0.5) best = up * wcol; } o = best; }
