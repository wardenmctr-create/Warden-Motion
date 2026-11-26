// copybg
uniform sampler2D s_kaynakKatm, s_bgsrc; uniform float p_kaynakKatmOn, p_bgsrcOn; uniform float p_kaynak, p_opaklik, p_alfaylaKirp, p_yalnizArkaPlan; uniform vec2 p_kayma;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here() - p_kayma * u_s);
  vec4 bg = (p_kaynak > 0.5 && p_kaynakKatmOn > 0.5) ? texture(s_kaynakKatm, clamp(b, 0.0, 1.0)) : (p_bgsrcOn > 0.5 ? texture(s_bgsrc, clamp(b, 0.0, 1.0)) : vec4(0.5, 0.5, 0.5, 1.0) * 0.0 + s);
  bg *= p_opaklik / 100.0; if (p_alfaylaKirp > 0.5) bg *= s.a;
  o = p_yalnizArkaPlan > 0.5 ? bg : overPre(s, bg);
}
