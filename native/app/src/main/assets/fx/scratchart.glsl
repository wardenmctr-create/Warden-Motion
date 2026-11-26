// scratchart
uniform sampler2D s_altKatm, s_elleKaziMask; uniform float p_altKatmOn, p_elleKaziMaskOn;
uniform float p_altRenkKayn, p_cizgiGeni, p_cizgiYogu, p_kenarDuze, p_kazimaIler; uniform vec3 c_ustYuzeReng, c_altRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float L = luma(unpre(s)); vec2 gdir = lumGrad(here(), 1.5 * u_s); float e = smoothstep(0.08, 0.3, sobel(here(), u_s));
  float ang = length(gdir) > 0.01 ? degrees(atan(gdir.y, gdir.x)) + 90.0 : 45.0; vec2 r = rot2(-ang) * q; float sp = max(p_cizgiGeni * 3.0, 2.0);
  float wob = pnoise(q * 0.05) * p_kenarDuze / 100.0 * sp; float line = 1.0 - smoothstep(p_cizgiGeni * 0.5, p_cizgiGeni * 0.5 + 0.7 / u_s, abs(mod(r.y + wob, sp) - sp * 0.5));
  float scratch = max(e, line * smoothstep(1.0 - p_cizgiYogu / 100.0, 1.0, L + 0.2)); if (p_elleKaziMaskOn > 0.5) scratch = max(scratch, texture(s_elleKaziMask, clamp(boxUV(here()), 0.0, 1.0)).a);
  scratch *= step(hash1(floor(q / 40.0)), p_kazimaIler / 100.0 * 1.001);
  vec3 under = p_altRenkKayn < 0.5 ? unpre(s) : p_altRenkKayn < 1.5 ? hsv2rgb(vec3(fract(q.x / max(boxU().x, 1.0) + q.y / max(boxU().y, 1.0) * 0.5), 0.8, 1.0)) : p_altRenkKayn < 2.5 ? c_altRenk : (p_altKatmOn > 0.5 ? unpre(texture(s_altKatm, clamp(boxUV(here()), 0.0, 1.0))) : c_altRenk);
  o = pre(mix(c_ustYuzeReng, under, clamp(scratch, 0.0, 1.0)), s.a); }
