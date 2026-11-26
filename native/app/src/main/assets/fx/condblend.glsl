// condblend
uniform sampler2D s_aB; uniform float p_aBOn, p_kanal, p_esik, p_yumusatm;
void main() { vec4 s = texture(u_tex, v_uv); if (p_aBOn < 0.5) { o = s; return; } vec4 b = texture(s_aB, clamp(boxUV(here()), 0.0, 1.0)); vec3 u = unpre(s); float v = p_kanal < 0.5 ? luma(u) : p_kanal < 1.5 ? u.r : p_kanal < 2.5 ? u.g : p_kanal < 3.5 ? u.b : s.a;
  float w = smoothstep(p_esik / 100.0 - p_yumusatm / 200.0 - 1e-3, p_esik / 100.0 + p_yumusatm / 200.0 + 1e-3, v); o = mix(b, s, w); }
