// lightwrap
uniform sampler2D s_bgsrc, s_isikKatm; uniform float p_bgsrcOn, p_isikKatmOn;
uniform float p_isikKayn, p_sarmaGeni, p_kaynakBula, p_guc, p_esik, p_alfayiKoru, p_doygunlu;
vec3 bgAt(vec2 px) { vec2 b = clamp(boxUV(px), 0.0, 1.0); if (p_isikKayn > 0.5 && p_isikKatmOn > 0.5) return unpre(texture(s_isikKatm, b)); if (p_bgsrcOn > 0.5) return unpre(texture(s_bgsrc, b)); return vec3(0.5); }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float W = max(p_sarmaGeni, 0.5) * u_s; float d = innerDist(here(), W); float k = 1.0 - smoothstep(0.0, W, d);
  vec3 acc = vec3(0.0); float br = max(p_kaynakBula, 1.0) * u_s; for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; acc += bgAt(here() + vec2(cos(a), sin(a)) * br * (0.3 + 0.7 * fract(float(i) * 0.618))); } acc /= 12.0;
  acc = satAdj(acc, p_doygunlu / 100.0); float lum = smoothstep(p_esik / 100.0, p_esik / 100.0 + 0.2, luma(acc)); vec3 c = unpre(s); c = screenB(c, acc * k * lum * p_guc / 100.0 * 1.5);
  o = pre(clamp(c, 0.0, 1.0), s.a); }
