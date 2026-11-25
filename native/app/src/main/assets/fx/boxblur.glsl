// boxblur
uniform vec2 u_dir; uniform float p_amount;
void main() { float r = p_amount * u_s * 0.5; if (r < 0.5) { o = texture(u_tex, v_uv); return; } float st = max(1.0, r / 24.0); int n = int(ceil(r / st)); vec4 acc = vec4(0.0); float c = 0.0;
  for (int i = -24; i <= 24; i++) { if (i < -n || i > n) continue; acc += tex(v_uv + u_dir * float(i) * st / u_res); c += 1.0; } o = acc / c; }
