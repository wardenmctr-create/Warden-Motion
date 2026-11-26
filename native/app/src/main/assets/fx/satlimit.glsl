// satlimit
uniform float p_doygunluTava, p_yumusakSini;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); float L = luma(c); vec3 ch = c - L; float sat = length(ch) * 1.7;
  float cap = p_doygunluTava / 100.0 * mix(0.6, 1.0, 1.0 - abs(2.0 * L - 1.0)); float ns = p_yumusakSini > 0.5 ? cap * tanh(sat / max(cap, 1e-3)) : min(sat, cap);
  o = pre(clamp(L + ch * (ns / max(sat, 1e-4)), 0.0, 1.0), s.a); }
