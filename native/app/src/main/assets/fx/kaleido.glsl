// kaleido
uniform vec2 p_merkez; uniform float p_dilimSayi, p_aci, p_olcek, p_aynala, p_birlesimYumu;
void main() {
  vec2 q = toUnit(here()); vec2 r = q - p_merkez; float d = length(r);
  float seg = TAU / max(2.0, floor(p_dilimSayi));
  float a = atan(r.y, r.x) - radians(p_aci); a = mod(a, seg);
  if (p_aynala > 0.5) a = min(a, seg - a);
  vec2 src = p_merkez + vec2(cos(a + radians(p_aci)), sin(a + radians(p_aci))) * d / max(p_olcek / 100.0, 0.01);
  vec4 c = texU(src);
  if (p_birlesimYumu > 0.01) { float e = min(mod(atan(r.y, r.x) - radians(p_aci), seg), seg - mod(atan(r.y, r.x) - radians(p_aci), seg)) * d; c *= mix(0.85, 1.0, smoothstep(0.0, p_birlesimYumu, e)); }
  o = c;
}
