// gradwipe
uniform sampler2D s_haritaKatm; uniform float p_haritaKatmOn; uniform float p_ilerleme, p_harita, p_yumusakl, p_olcek, p_ters;
void main() { vec4 s = texture(u_tex, v_uv); float m; if (p_harita > 1.5 && p_haritaKatmOn > 0.5) m = luma(unpre(texture(s_haritaKatm, clamp(boxUV(here()), 0.0, 1.0))));
  else if (p_harita > 0.5) m = fbm(toUnit(here()) / max(p_olcek, 1.0), 4.0) * 0.5 + 0.5; else m = luma(unpre(s)); if (p_ters > 0.5) m = 1.0 - m;
  float w = p_yumusakl / 100.0 * 0.5 + 1e-3; float pr = p_ilerleme / 100.0 * (1.0 + 2.0 * w) - w; o = s * smoothstep(pr - w, pr + w, m); }
