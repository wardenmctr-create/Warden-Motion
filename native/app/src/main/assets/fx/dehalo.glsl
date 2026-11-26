// dehalo
uniform sampler2D s_korumaMask; uniform float p_korumaMaskOn;
uniform float p_halkaGeni, p_kenarEsig, p_halkaTuru, p_guc, p_renkKoru, p_dokuKoru, p_halkaMaskGost;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float R = max(p_halkaGeni, 0.5) * u_s; vec3 mn = vec3(1.0), mx = vec3(0.0);
  for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; vec3 c = unpre(texPx(here() + vec2(cos(a), sin(a)) * R * 1.6)); mn = min(mn, c); mx = max(mx, c); }
  float edge = smoothstep(p_kenarEsig / 100.0 * 0.5, p_kenarEsig / 100.0, length(mx - mn)); vec3 cl = clamp(c0, mn, mx);
  vec3 r = c0; if (p_halkaTuru < 0.5 || p_halkaTuru > 1.5) r = min(r, max(cl, mn)); if (p_halkaTuru > 0.5) r = max(r, min(cl, mx));
  float tex = smoothstep(0.05, 0.2, length(c0 - unpre(texPx(here() + vec2(u_s, u_s))))) * p_dokuKoru / 100.0 * 0.5; float w = edge * p_guc / 100.0 * (1.0 - tex);
  if (p_korumaMaskOn > 0.5) w *= 1.0 - texture(s_korumaMask, clamp(boxUV(here()), 0.0, 1.0)).a;
  if (p_halkaMaskGost > 0.5) { o = vec4(vec3(w), 1.0); return; } vec3 res = mix(c0, r, w); res = mix(res, luma(res) + (c0 - luma(c0)), p_renkKoru / 100.0 * 0.5); o = pre(clamp(res, 0.0, 1.0), s.a); }
