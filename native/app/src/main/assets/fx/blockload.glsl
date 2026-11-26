// blockload
uniform float p_yuklemeIler, p_blokBoyu, p_sira, p_tohum, p_renkOrta;
void main() {
  vec2 px = here(); float bs0 = max(p_blokBoyu * u_s, 2.0); vec2 b = boxUV(px);
  float order = p_sira < 0.5 ? hash1(floor((px - u_box.xy) / bs0) + seedf(p_tohum)) : p_sira < 1.5 ? b.y : 1.0 - b.y;
  float p = p_yuklemeIler / 100.0;
  float lev = clamp(p * 4.0 - order * 2.0, 0.0, 3.0);
  float bs = lev >= 3.0 ? 1.0 : bs0 / pow(2.0, floor(lev) * 1.5);
  if (lev <= 0.0) { o = vec4(0.0); return; }
  if (bs <= 1.0) { o = texPx(px); return; }
  vec2 c0 = floor((px - u_box.xy) / bs) * bs + u_box.xy; vec4 c = p_renkOrta > 0.5 ? (texPx(c0 + bs * 0.25) + texPx(c0 + bs * 0.75) + texPx(c0 + vec2(bs * 0.25, bs * 0.75)) + texPx(c0 + vec2(bs * 0.75, bs * 0.25))) * 0.25 : texPx(c0 + bs * 0.5);
  o = c;
}
