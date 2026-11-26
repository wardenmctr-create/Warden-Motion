// lensdirt
uniform sampler2D s_ozelDoku; uniform float p_ozelDokuOn;
uniform float p_lekeTuru, p_yogunluk, p_buyukluk, p_tohum, p_parlakliEsig, p_guc, p_yumusakl, p_ekranaSabi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 q = p_ekranaSabi > 0.5 ? b * vec2(boxU().x / max(boxU().y, 1.0), 1.0) * 400.0 : toUnit(here()); float sd = seedf(p_tohum); float dirt = 0.0;
  if (p_lekeTuru > 2.5 && p_ozelDokuOn > 0.5) dirt = luma(unpre(texture(s_ozelDoku, fract(b))));
  else { float sz = max(p_buyukluk, 1.0); for (int l = 0; l < 3; l++) { float cs = sz * (2.0 + float(l) * 1.5); vec2 g = q / cs; vec2 id = floor(g); vec2 h = hash2(id + sd + float(l) * 9.0);
      if (h.x > p_yogunluk / 100.0) continue; vec2 c = id + 0.2 + h * 0.6; float r = (0.15 + hash1(id + 3.0) * 0.3); float dd = length(g - c);
      float dust = 1.0 - smoothstep(r * 0.5, r * 0.5 + max(p_yumusakl, 0.5) / cs, dd); float oil = (1.0 - smoothstep(r, r + 0.2, dd)) * (0.4 + 0.6 * fbm01(g * 3.0, 3.0));
      float t = p_lekeTuru < 0.5 ? dust : p_lekeTuru < 1.5 ? oil : (hash1(id) > 0.5 ? dust : oil); dirt = max(dirt, t); } }
  vec3 acc = vec3(0.0); float R = 30.0 * u_s; for (int i = 0; i < 12; i++) { float a = float(i) * 0.5236; acc += unpre(texPx(here() + vec2(cos(a), sin(a)) * R * fract(float(i) * 0.618 + 0.2))); } acc /= 12.0;
  float light = smoothstep(p_parlakliEsig / 100.0 - 0.1, p_parlakliEsig / 100.0 + 0.1, luma(acc)); vec3 c = unpre(s) + acc * dirt * light * p_guc / 100.0 * 1.2; o = pre(clamp(c, 0.0, 1.0), s.a); }
