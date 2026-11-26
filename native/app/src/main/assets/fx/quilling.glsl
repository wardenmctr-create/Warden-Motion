// quilling
uniform float p_seritGeni, p_seritYuks, p_kivrimYari, p_turSayi, p_doluluk, p_kivrimBici, p_dokuGucu, p_golgeGucu, p_kaynakRengKull, p_olusumIler;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float R = max(p_kivrimYari, 3.0); vec4 v = voronoi(q / (R * 2.0)); vec2 cid = v.zw;
  vec2 ctr = (floor(q / (R * 2.0)) + 0.0) * R * 2.0; vec4 vv = voronoi(q / (R * 2.0)); vec2 c0 = q / (R * 2.0); // yerel koordinat: hücre merkezine göre
  vec2 g = floor(c0); vec2 bestP = vec2(0.0); float best = 1e9; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = g + vec2(i, j); vec2 p = id + hash2(id); float d = length(c0 - p); if (d < best) { best = d; bestP = p; cid = id; } }
  vec2 l = (c0 - bestP) * R * 2.0; float k = p_kivrimBici > 2.5 ? floor(hash1(cid) * 3.0) : p_kivrimBici; if (k > 0.5 && k < 1.5) l.y += max(0.0, -l.y) * 0.0 + l.x * l.x / R * 0.3; if (k > 1.5) l.x *= 1.6;
  float r = length(l); float a = atan(l.y, l.x); float turns = max(p_turSayi, 0.5); float pitch = R / turns; float sp = fract((r - a / TAU * pitch) / pitch);
  float strip = 1.0 - smoothstep(0.0, max(p_seritGeni / pitch, 0.05) * 0.5, abs(sp - 0.5) - 0.5 + max(p_seritGeni / pitch, 0.05) * 0.5);
  strip *= step(r, R * p_doluluk / 100.0 * 1.2) * step(hash1(cid + 4.0), p_olusumIler / 100.0);
  vec4 src = texU(bestP * R * 2.0); float inside = src.a; vec3 col = p_kaynakRengKull > 0.5 && src.a > 0.0 ? src.rgb / src.a : vec3(0.95, 0.9, 0.8);
  float ridge = sin(sp * PI); col *= 0.7 + 0.3 * ridge * (1.0 + p_seritYuks / 20.0) * 0.8; col *= 1.0 - (vnoise(q * 0.8) - 0.5) * p_dokuGucu / 100.0 * 0.3;
  float shadow = (1.0 - strip) * p_golgeGucu / 100.0 * 0.4 * step(r, R * p_doluluk / 100.0 * 1.2);
  o = pre(clamp(col * (strip > 0.0 ? 1.0 : 1.0 - shadow), 0.0, 1.0), inside * max(strip, shadow * 0.5)); }
