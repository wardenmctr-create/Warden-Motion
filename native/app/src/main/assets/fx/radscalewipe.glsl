// radscalewipe
uniform vec2 p_merkez; uniform float p_ilerleme, p_olcek, p_yumusatm, p_ters;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; float R = pr * length(B) * 0.6; vec2 r = q - p_merkez; float d = length(r);
  float k = smoothstep(R - p_yumusatm, R + 1e-3, d); float push = 1.0 + (p_olcek / 100.0 - 1.0) * pr; vec2 src = p_merkez + r / push * max(1.0 - R / max(d, 1e-3), 0.0) + (d > 0.0 ? r / d : vec2(0.0)) * 0.0;
  src = p_merkez + (d > 0.0 ? r / d : vec2(0.0)) * max(d - R, 0.0) / push * push; o = texU(mix(q, src, pr)) * k; }
