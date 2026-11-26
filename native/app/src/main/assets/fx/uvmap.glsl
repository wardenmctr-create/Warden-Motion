// uvmap
uniform sampler2D s_uvKatm, s_kaplanacKatm; uniform float p_uvKatmOn, p_kaplanacKatmOn;
uniform float p_dokuDonu, p_tasma, p_orneklem, p_alfayiKoru; uniform vec2 p_dokuOlce, p_dokuKaym;
void main() { vec4 s = texture(u_tex, v_uv); if (p_uvKatmOn < 0.5 || p_kaplanacKatmOn < 0.5) { o = s; return; } vec4 m = texture(s_uvKatm, clamp(boxUV(here()), 0.0, 1.0)); if (m.a <= 0.0) { o = p_alfayiKoru > 0.5 ? vec4(0.0) : s; return; }
  vec2 uv = unpre(m).rg; uv = rot2(-p_dokuDonu) * (uv - 0.5) / max(p_dokuOlce / 100.0, vec2(0.01)) + 0.5 + p_dokuKaym / 100.0;
  bool out_ = any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0))); if (p_tasma > 0.5 && p_tasma < 1.5) uv = fract(uv); else if (p_tasma > 1.5 && p_tasma < 2.5) { uv = abs(mod(uv, 2.0)); uv = mix(uv, 2.0 - uv, step(1.0, uv)); } else uv = clamp(uv, 0.0, 1.0);
  vec4 c = texture(s_kaplanacKatm, uv); if (p_tasma < 0.5 && out_) c = vec4(0.0); o = c * (p_alfayiKoru > 0.5 ? m.a : 1.0); }
