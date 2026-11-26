// graddisp
uniform vec2 p_baslangi, p_bitis, p_yerDegi; uniform float p_gecisTuru, p_tersCevi;
void main() {
  vec2 q = toUnit(here()); vec2 ab = p_bitis - p_baslangi; float w;
  if (p_gecisTuru < 0.5) w = clamp(dot(q - p_baslangi, ab) / max(dot(ab, ab), 1.0), 0.0, 1.0);
  else w = clamp(length(q - p_baslangi) / max(length(ab), 1.0), 0.0, 1.0);
  w = smoothstep(0.0, 1.0, w); if (p_tersCevi > 0.5) w = 1.0 - w;
  o = texU(q - p_yerDegi / 100.0 * boxU() * w);
}
