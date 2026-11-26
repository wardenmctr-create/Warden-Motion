// glitch
uniform float p_blokMikt, p_blokBoyu, p_kayma, p_rgbAyri, p_taramaCizg, p_tekrarla, p_tohum, p_kareTut;
void main() {
  vec2 px = here(); float tq = p_kareTut > 0.5 ? floor(u_t * max(p_tekrarla, 0.01)) : u_t * p_tekrarla;
  float bs = max(p_blokBoyu, 1.0) * u_s; float sd = seedf(p_tohum);
  float by = floor((px.y - u_box.y) / bs);
  float r = hash1(vec2(by, tq + sd)); float r2 = hash1(vec2(by * 1.7, tq * 1.3 + sd + 5.0));
  float on = step(r, p_blokMikt / 100.0);
  // ikinci ölçekte küçük bloklar
  float bx = floor((px.x - u_box.x) / (bs * 3.0)); float on2 = step(hash1(vec2(bx, by + tq * 7.0 + sd)), p_blokMikt / 250.0);
  float sh = (on * (r2 * 2.0 - 1.0) + on2 * (hash1(vec2(bx, by)) - 0.5)) * p_kayma * u_s;
  float ca = (on + on2 * 0.5) * p_rgbAyri * u_s + p_rgbAyri * u_s * 0.15;
  vec2 p = px + vec2(sh, 0.0);
  vec4 c = vec4(texPx(p + vec2(ca, 0.0)).r, texPx(p).g, texPx(p - vec2(ca, 0.0)).b, 0.0);
  c.a = max(texPx(p).a, max(texPx(p + vec2(ca, 0.0)).a, texPx(p - vec2(ca, 0.0)).a));
  float sl = 1.0 - p_taramaCizg / 100.0 * 0.6 * step(0.5, fract(px.y / max(2.0, u_s * 2.0)));
  c.rgb *= sl;
  o = c;
}
