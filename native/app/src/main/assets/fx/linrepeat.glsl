// linrepeat
uniform float p_kopyaSayi, p_adimX, p_adimY, p_olcekAdim, p_donusAdim, p_opaklikAdim, p_orijinalGost;
void main() {
  vec2 q = toUnit(here()); vec4 res = vec4(0.0); int N = int(clamp(p_kopyaSayi, 1.0, 64.0));
  for (int i = 63; i >= 0; i--) { if (i >= N) continue; if (i == 0 && p_orijinalGost < 0.5) continue; float k = float(i); float sc = max(1.0 + p_olcekAdim / 100.0 * k, 0.01);
    vec2 c = vec2(p_adimX, p_adimY) * k; vec2 l = rot2(-p_donusAdim * k) * (q - c) / sc; float op = clamp(1.0 + p_opaklikAdim / 100.0 * k, 0.0, 1.0); res = overPre(texU(l) * op, res); }
  o = res;
}
