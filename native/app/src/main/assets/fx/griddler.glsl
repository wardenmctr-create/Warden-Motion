// griddler
uniform float p_satir, p_sutun, p_parcaDonu, p_parcaKaym, p_olcek, p_rastgele, p_tohum;
void main() {
  vec2 b = boxUV(here()); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir)));
  vec2 B = boxU();
  vec2 id = floor(b * n); vec2 cell = B / n; vec2 c = (id + 0.5) / n;
  vec2 rr = hash2(id + seedf(p_tohum));
  float ang = p_parcaDonu * mix(1.0, rr.x * 2.0 - 1.0, p_rastgele / 100.0);
  float sa = rr.y * TAU; vec2 sh = vec2(cos(sa), sin(sa)) * p_parcaKaym * mix(1.0, rr.x, p_rastgele / 100.0);
  vec2 lu = (b - c) * B - sh / 1.0; lu = rot2(-ang) * lu / max(p_olcek / 100.0, 0.01);
  vec2 sb = c + lu / B;
  if (any(greaterThan(abs(sb - c), 0.5 / n))) { o = vec4(0.0); return; }
  o = texPx(boxPx(sb));
}
