// cellpattern
uniform float p_hucreBoyu, p_desen, p_kenarKali, p_evrim, p_tohum, p_kenarYumu; uniform vec3 c_renk1, c_renk2;
void main() {
  vec2 p = toUnit(here()) / max(p_hucreBoyu, 1.0) + seedf(p_tohum); p += vec2(sin(p_evrim * 0.05), cos(p_evrim * 0.05)) * 0.3;
  vec4 v = voronoi(p); float edge = v.y - v.x; float w = p_kenarKali / max(p_hucreBoyu, 1.0); float aa = p_kenarYumu > 0.5 ? 0.04 : 0.005;
  float k;
  if (p_desen < 0.5) k = smoothstep(w - aa, w + aa, edge);
  else if (p_desen < 1.5) k = 1.0 - smoothstep(0.0, 0.7, v.x);
  else if (p_desen < 2.5) k = mix(0.3, 1.0, hash1(v.zw)) * smoothstep(w - aa, w + aa, edge);
  else k = step(0.5, hash1(v.zw)) * 0.6 + 0.4 * smoothstep(w - aa, w + aa, edge);
  o = genOver(vec4(mix(c_renk1, c_renk2, k), 1.0));
}
