// lensblur
uniform sampler2D s_derinlikKatm; uniform float p_derinlikKatmOn;
uniform float p_yaricap, p_diyaframSekl, p_diyaframAcis, p_kenarYuva, p_parlakNoktEsig, p_parlakNoktKaza;
float aperture(vec2 f) { // f: -1..1, şekil içinde mi
  float n = p_diyaframSekl < 0.5 ? 0.0 : p_diyaframSekl < 1.5 ? 3.0 : p_diyaframSekl < 2.5 ? 5.0 : p_diyaframSekl < 3.5 ? 6.0 : 8.0;
  if (n < 1.0) return step(length(f), 1.0);
  f = rot2(-p_diyaframAcis) * f; float a = atan(f.y, f.x); float seg = TAU / n; float d = cos(PI / n) / cos(mod(a, seg) - seg * 0.5);
  d = mix(d, 1.0, p_kenarYuva / 100.0 * 0.6); return step(length(f), d);
}
void main() {
  float R = p_yaricap * u_s * 0.5; float k = 1.0;
  if (p_derinlikKatmOn > 0.5) { vec4 dm = texture(s_derinlikKatm, clamp(boxUV(here()), 0.0, 1.0)); k = luma(unpre(dm)); }
  R *= k; if (R < 0.5) { o = texture(u_tex, v_uv); return; }
  vec4 acc = vec4(0.0); float ws = 0.0; float th = p_parlakNoktEsig / 100.0; float gain = p_parlakNoktKaza / 100.0 * 6.0;
  for (int j = -6; j <= 6; j++) for (int i = -6; i <= 6; i++) { vec2 f = vec2(float(i), float(j)) / 6.0; if (aperture(f) < 0.5) continue;
    vec4 c = texPx(here() + f * R + (hash2(vec2(float(i), float(j))) - 0.5) * R / 6.0); float l = c.a > 0.0 ? luma(c.rgb / c.a) : 0.0; float w = 1.0 + max(l - th, 0.0) / max(1.0 - th, 0.01) * gain; acc += c * w; ws += w; }
  o = acc / ws;
}
