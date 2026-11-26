// inkdraw
INCLUDE(_mat)
uniform float p_cizgiKali, p_kenarHass, p_ayrinti, p_cizgiDuze, p_murekkepYayi, p_murekkepYogu, p_orijinalRenkKoru, p_kagitDoku, p_kagitTuru, p_dokuGucu, p_taramaYogu, p_dinamikCizg, p_yenilenmAral; uniform vec3 c_murekkepReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float tick = p_dinamikCizg > 0.5 ? floor(u_t * 24.0 / max(p_yenilenmAral, 1.0)) : 0.0;
  vec2 j = (vec2(pnoise(q * 0.05 + tick * 1.7), pnoise(q * 0.05 + 9.0 + tick)) ) * p_cizgiDuze / 100.0 * 3.0 * u_s; vec2 px = here() + j;
  float st = max(p_cizgiKali * u_s * 0.6, 0.6); float e = sobel(px, st) * (0.5 + p_kenarHass / 50.0); float ea = length(alphaGrad(px, st)) * 2.0;
  float detail = mix(0.6, 0.15, p_ayrinti / 100.0); float line = smoothstep(detail, detail + 0.25, max(e, ea));
  float bleed = 0.0; if (p_murekkepYayi > 0.0) { for (int i = 0; i < 6; i++) { float a = float(i) * 1.047; bleed = max(bleed, sobel(px + vec2(cos(a), sin(a)) * p_murekkepYayi * u_s, st)); } line = max(line, smoothstep(detail + 0.2, detail + 0.6, bleed) * 0.6); }
  float L = luma(unpre(s)); float hatch = 0.0; if (p_taramaYogu > 0.0) { vec2 r = rot2(45.0) * q; float h1 = step(0.5, fract(r.y / 5.0)) * step(L, 0.45); vec2 r2 = rot2(-45.0) * q; float h2 = step(0.5, fract(r2.y / 5.0)) * step(L, 0.25);
    hatch = max(h1, h2) * p_taramaYogu / 100.0 * (0.7 + 0.3 * pnoise(q * 0.3)); }
  float ink = clamp(max(line, hatch) * p_murekkepYogu / 100.0, 0.0, 1.0) * s.a;
  int id = p_kagitTuru < 0.5 ? 1 : p_kagitTuru < 1.5 ? 6 : p_kagitTuru < 2.5 ? 9 : 3; vec3 paper = vec3(1.0);
  if (p_kagitDoku > 0.5) { vec3 m = matSample(id, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb; paper = mix(vec3(1.0), m / max(luma(matBase(id)), 0.05) * (id == 1 ? 1.0 : 0.85), p_dokuGucu / 100.0 * 2.0); }
  vec3 base = mix(paper, unpre(s) * paper, p_orijinalRenkKoru / 100.0); vec3 c = mix(base, c_murekkepReng, ink); o = pre(clamp(c, 0.0, 1.0), s.a); }
