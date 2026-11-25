// depthblur
uniform sampler2D u_depth; uniform float p_focus; uniform float p_amount; uniform float p_range;
void main() { float z = texture(u_depth, v_uv).r * 100.0; float k = smoothstep(p_range * 0.5, p_range * 0.5 + 25.0, abs(z - p_focus)); float r = p_amount * u_s * k;
  if (r < 0.5) { o = texture(u_tex, v_uv); return; } vec4 acc = vec4(0.0); float ws = 0.0;
  for (int i = 0; i < 64; i++) { float f = float(i) + 0.5; float a = f * 2.39996; vec2 q = vec2(cos(a), sin(a)) * sqrt(f / 64.0) * r / u_res; vec4 t = tex(v_uv + q); float w = 1.0 + pow(luma(t.rgb), 4.0) * 6.0; acc += t * w; ws += w; } o = acc / ws; }
