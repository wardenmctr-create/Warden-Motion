// crossblur
uniform vec2 u_dir; uniform float p_h; uniform float p_v;
void main() { float r = (u_dir.x > 0.5 ? p_h : p_v) * u_s * 0.5; if (r < 0.5) { o = texture(u_tex, v_uv); return; } vec4 acc = vec4(0.0); float ws = 0.0;
  for (int i = -24; i <= 24; i++) { float x = float(i) / 24.0; float w = exp(-x * x * 3.0); acc += tex(v_uv + u_dir * x * r / u_res) * w; ws += w; } o = acc / ws; }
