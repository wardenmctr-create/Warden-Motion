// exposurefuse
uniform sampler2D s_koyuPozl, s_ortaPozl, s_acikPozl; uniform float p_koyuPozlOn, p_ortaPozlOn, p_acikPozlOn;
uniform float p_pozlamaAgir, p_kontrastAgir, p_doygunluAgir, p_gecisYumu;
float wt(vec3 c, vec3 cx, vec3 cy) { float well = exp(-pow(luma(c) - 0.5, 2.0) / 0.08); float con = abs(luma(cx) + luma(cy) - 2.0 * luma(c)) * 4.0; float sat = length(c - luma(c));
  return 1e-3 + pow(well, p_pozlamaAgir / 50.0) * (1.0 + con * p_kontrastAgir / 50.0) * (1.0 + sat * p_doygunluAgir / 50.0); }
vec4 img(int i, vec2 uv) { if (i == 0) return p_koyuPozlOn > 0.5 ? texture(s_koyuPozl, uv) : vec4(0.0); if (i == 1) return p_ortaPozlOn > 0.5 ? texture(s_ortaPozl, uv) : texPx(boxPx(uv)); return p_acikPozlOn > 0.5 ? texture(s_acikPozl, uv) : vec4(0.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 uv = clamp(boxUV(here()), 0.0, 1.0); vec2 e = vec2(1.0 / max(u_box.z, 1.0), 0.0) * (1.0 + p_gecisYumu / 10.0); vec3 acc = vec3(0.0); float ws = 0.0;
  for (int i = 0; i < 3; i++) { vec4 c = img(i, uv); if (c.a <= 0.0) continue; vec3 u = unpre(c); float w = wt(u, unpre(img(i, uv + e)), unpre(img(i, uv + e.yx)));
    float wb = 0.0; for (int k = 0; k < 4; k++) { vec2 o2 = vec2(cos(float(k) * 1.57), sin(float(k) * 1.57)) * e.x * 6.0; vec3 cc = unpre(img(i, uv + o2)); wb += wt(cc, cc, cc); } w = mix(w, wb / 4.0, p_gecisYumu / 100.0);
    acc += u * w; ws += w; }
  o = ws > 0.0 ? pre(clamp(acc / ws, 0.0, 1.0), s.a) : s; }
