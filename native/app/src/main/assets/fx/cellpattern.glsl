// cellpattern
uniform float p_hucreBoyu, p_desen, p_kenarKali, p_evrim, p_tohum, p_kenarYumu, p_duzensiz, p_esneklik, p_bosluk, p_kabartma, p_renklendir, p_merkezGoster; uniform vec2 p_oran; uniform vec3 c_renk1, c_renk2;
vec4 vor(vec2 p, float jit) { vec2 i = floor(p), f = fract(p); float d1 = 8.0, d2 = 8.0; vec2 id = vec2(0.0), cpos = vec2(0.0);
  for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) { vec2 g = vec2(float(x), float(y)); vec2 o2 = mix(vec2(0.5), hash2(i + g), jit); o2 += (vec2(sin(p_evrim * 0.05 + hash1(i + g) * 6.0), cos(p_evrim * 0.05 + hash1(i + g + 1.0) * 6.0))) * 0.15 * p_esneklik / 100.0;
    vec2 r = g + o2 - f; float d = dot(r, r); if (d < d1) { d2 = d1; d1 = d; id = i + g; cpos = r; } else if (d < d2) d2 = d; }
  return vec4(sqrt(d1), sqrt(d2), id); }
void main() {
  vec2 p = toUnit(here()) / (max(p_hucreBoyu, 1.0) * max(p_oran, vec2(1.0)) / 100.0) + seedf(p_tohum);
  vec4 v = vor(p, p_duzensiz / 100.0); float edge = v.y - v.x; float w = p_kenarKali / max(p_hucreBoyu, 1.0) + p_bosluk / max(p_hucreBoyu, 1.0); float aa = p_kenarYumu > 0.5 ? 0.04 : 0.005;
  float k; if (p_desen < 0.5) k = smoothstep(w - aa, w + aa, edge); else if (p_desen < 1.5) k = 1.0 - smoothstep(0.0, 0.7, v.x); else if (p_desen < 2.5) k = mix(0.3, 1.0, hash1(v.zw)) * smoothstep(w - aa, w + aa, edge); else k = step(0.5, hash1(v.zw)) * 0.6 + 0.4 * smoothstep(w - aa, w + aa, edge);
  vec3 cell = c_renk2;
  if (p_renklendir > 0.5 && p_renklendir < 1.5) cell = hsv2rgb(vec3(hash1(v.zw), 0.6, 0.9)); else if (p_renklendir > 1.5 && p_renklendir < 2.5) cell = unpre(texU((v.zw + 0.5 - seedf(p_tohum)) * max(p_hucreBoyu, 1.0))); else if (p_renklendir > 2.5) cell = mix(c_renk1, c_renk2, hash1(v.zw));
  vec3 col = mix(c_renk1, cell, k); col *= 1.0 + (0.5 - v.x) * p_kabartma / 100.0 * 0.8;
  if (p_bosluk > 0.0) { float gap = 1.0 - smoothstep(0.0, p_bosluk / max(p_hucreBoyu, 1.0) + 0.01, edge); col = mix(col, c_renk1, gap); }
  if (p_merkezGoster > 0.5) col = mix(col, vec3(1.0), 1.0 - smoothstep(0.03, 0.06, v.x));
  o = genOver(vec4(col, 1.0));
}
