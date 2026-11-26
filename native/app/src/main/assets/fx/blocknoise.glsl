// blocknoise
uniform float p_blokBoyu, p_renkCesi, p_yogunluk, p_yenilenm, p_tohum, p_tekRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 id = floor(toUnit(here()) / max(p_blokBoyu, 1.0)); float tk = floor(u_t * p_yenilenm); float sd = seedf(p_tohum);
  float on = step(hash1(id + tk * 7.1 + sd), p_yogunluk / 100.0);
  vec3 c = p_tekRenk > 0.5 ? vec3(hash1(id + tk + sd + 3.0)) : mix(vec3(hash1(id + tk + 1.0)), hsv2rgb(vec3(hash1(id + tk + 5.0 + sd), 0.9, 0.95)), p_renkCesi / 100.0);
  o = genOver(vec4(c, 1.0) * on);
}
