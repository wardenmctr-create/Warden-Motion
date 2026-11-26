// cinemagraph
INCLUDE(_hist)
uniform sampler2D s_hareketMask; uniform float p_hareketMaskOn, p_maskeyiTersCevi, p_kenarYumu, p_maskeOniz;
void main() { vec4 s = texture(u_tex, v_uv); vec4 fr = histN() > 0.0 ? hist(0.0, v_uv) : s; float m = 0.0; float R = max(p_kenarYumu, 0.5) * u_s;
  if (p_hareketMaskOn > 0.5) { for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; m += texture(s_hareketMask, clamp(boxUV(here() + vec2(cos(a), sin(a)) * R * fract(float(i) * 0.618 + 0.2)), 0.0, 1.0)).a; } m /= 12.0; } else m = 1.0 - smoothstep(0.25, 0.35, length(boxUV(here()) - 0.5));
  if (p_maskeyiTersCevi > 0.5) m = 1.0 - m; vec4 c = mix(fr, s, m); if (p_maskeOniz > 0.5 && u_export < 0.5) c = overPre(vec4(1.0, 0.2, 0.2, 1.0) * m * 0.35, c); o = c; }
