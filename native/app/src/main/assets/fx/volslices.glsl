// volslices
uniform sampler2D s_dilimDizi; uniform float p_dilimDiziOn;
uniform float p_dilimKayn, p_dilimSayi, p_dilimAral, p_sonOlce, p_dilimDonu, p_dilimOpak, p_uzakSolm, p_derinlikSira;
void main() { vec2 q = toUnit(here()); int N = int(clamp(p_dilimSayi, 1.0, 48.0)); vec4 res = vec4(0.0);
  for (int i = 0; i < 48; i++) { if (i >= N) break; int k = p_derinlikSira > 0.5 ? N - 1 - i : i; float f = float(k) / max(float(N - 1), 1.0); float sc = mix(1.0, p_sonOlce / 100.0, f);
    vec2 l = rot2(-p_dilimDonu * f) * (q - vec2(0.0, -p_dilimAral * float(k) * 0.5)) / max(sc, 0.05); vec4 c = texU(l);
    if (p_dilimKayn > 0.5 && p_dilimDiziOn > 0.5) { vec2 b = clamp(boxUV(fromUnit(l)), 0.0, 1.0); c = texture(s_dilimDizi, vec2((b.x + float(k)) / float(N), b.y)); }
    float lum = luma(c.a > 0.0 ? c.rgb / c.a : vec3(0.0)); float band = smoothstep(f - 0.6 / float(N), f, lum) * (p_dilimKayn < 0.5 ? 1.0 : 1.0);
    c *= p_dilimOpak / 100.0 * (1.0 - f * p_uzakSolm / 100.0) * (p_dilimKayn < 0.5 ? mix(1.0, band, 0.7) : 1.0); res = overPre(c, res); }
  o = res; }
