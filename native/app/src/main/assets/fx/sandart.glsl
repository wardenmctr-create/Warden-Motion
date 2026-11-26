// sandart
uniform float p_tanecikCapi, p_boyutRast, p_yogunluk, p_yiginYuks, p_renkSayi, p_renkVary, p_golgeGucu, p_serpilmeIler, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float d = max(p_tanecikCapi, 0.5); vec2 g = q / d; vec2 id = floor(g); vec2 h = hash2(id + seedf(p_tohum));
  float sz = 0.5 * (1.0 + (h.x - 0.5) * p_boyutRast / 50.0); float grain = 1.0 - smoothstep(sz * 0.8, sz, length(fract(g) - 0.5 - (h - 0.5) * 0.3));
  vec4 src = texPx(fromUnit((id + 0.5) * d)); vec3 c = src.a > 0.0 ? src.rgb / src.a : vec3(0.0); float k = pow(max(p_renkSayi, 2.0), 1.0 / 3.0); c = floor(c * k + 0.5) / k;
  c *= 1.0 + (hash1(id + 3.0) - 0.5) * p_renkVary / 100.0 * 1.5; float heap = fbm01(q * 0.05, 3.0) * p_yiginYuks / 10.0; vec2 gr = vec2(fbm01(q * 0.05 + vec2(0.5, 0.0), 3.0), fbm01(q * 0.05 + vec2(0.0, 0.5), 3.0)) - fbm01(q * 0.05, 3.0);
  c *= 1.0 - (gr.x + gr.y) * p_golgeGucu / 100.0 * 4.0 * p_yiginYuks / 3.0; float present = step(hash1(id + 9.0), p_yogunluk / 100.0) * step(hash1(id + 11.0), p_serpilmeIler / 100.0);
  o = pre(clamp(c, 0.0, 1.0), src.a * grain * present); }
