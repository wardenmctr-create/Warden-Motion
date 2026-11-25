// bilateral
uniform float p_amount; uniform float p_thr;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c0 = unpre(s); float r = p_amount * u_s; vec3 acc = vec3(0.0); float ws = 0.0; float sig = max(0.01, p_thr / 100.0 * 0.5);
  for (int y = -4; y <= 4; y++) for (int x = -4; x <= 4; x++) { vec2 o2 = vec2(x, y) / 4.0; vec4 t = tex(v_uv + o2 * r / u_res); if (t.a <= 0.0) continue; vec3 c = unpre(t);
    float w = exp(-dot(o2, o2) * 2.0) * exp(-dot(c - c0, c - c0) / (2.0 * sig * sig)); acc += c * w; ws += w; }
  o = pre(acc / ws, s.a); }
