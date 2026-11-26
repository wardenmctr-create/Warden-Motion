// localcontrast
uniform float p_yaricap, p_guc, p_kenarKoru;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s); float L = luma(c); float R = max(p_yaricap, 1.0) * u_s; float acc = 0.0, ws = 0.0;
  for (int i = 0; i < 32; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 32.0); float w = exp(-r * r / (R * R) * 1.5); acc += luma(unpre(texPx(here() + vec2(cos(a), sin(a)) * r))) * w; ws += w; }
  float base = acc / ws; float det = L - base; float edge = smoothstep(0.08, 0.3, abs(det)) * p_kenarKoru / 100.0; float nl = L + det * p_guc / 100.0 * (1.0 - edge * 0.8);
  o = pre(clamp(c * (nl / max(L, 1e-3)), 0.0, 1.0), s.a); }
