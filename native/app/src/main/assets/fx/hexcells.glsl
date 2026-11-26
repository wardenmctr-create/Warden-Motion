// hexcells
uniform float p_hucreBoyu, p_yanmaOran, p_hiz, p_gecis, p_tohum, p_kontur; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 q = toUnit(here()); float sz = max(p_hucreBoyu, 2.0); vec4 h = hexGrid(q, sz); float r = hash1(h.zw + seedf(p_tohum));
  float ph = fract(u_t * p_hiz * 0.5 + r); float lit = smoothstep(1.0 - p_yanmaOran / 100.0 - p_gecis / 200.0, 1.0 - p_yanmaOran / 100.0 + p_gecis / 200.0 + 0.001, 0.5 + 0.5 * sin(ph * TAU));
  vec3 c = mix(c_renk1, c_renk2, lit); float d = hexDist((q - h.xy) / sz);
  if (p_kontur > 0.5) c = mix(c, c_renk2, smoothstep(0.44, 0.48, d) * 0.8);
  o = genOver(vec4(c, 1.0));
}
