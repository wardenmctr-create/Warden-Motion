// cubism
uniform float p_duzlemSayi, p_ortusme, p_donusFark, p_konumFark, p_geometriSert, p_renkFark, p_paletSayi, p_kaynagaSada, p_tohum;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cs = sqrt(boxU().x * boxU().y / max(p_duzlemSayi, 2.0)); vec2 g = q / cs; float sd = seedf(p_tohum);
  vec2 w = g + (vec2(pnoise(g * 0.7 + sd), pnoise(g * 0.7 + sd + 5.0))) * p_ortusme / 100.0 * (1.0 - p_geometriSert / 100.0); vec4 v = voronoi(w + sd); vec2 h = hash2(v.zw + 2.0) - 0.5;
  vec2 ctr = q; vec2 sq = rot2(h.x * p_donusFark) * q + h * p_konumFark; vec4 src = mix(texU(sq), texU(q), p_kaynagaSada / 100.0 * 0.5); vec3 c = src.a > 0.0 ? src.rgb / src.a : vec3(0.0);
  c *= 1.0 + h.y * p_renkFark / 100.0; float k = pow(max(p_paletSayi, 2.0), 1.0 / 3.0); c = floor(c * k + 0.5) / k; float edge = 1.0 - smoothstep(0.0, 0.04, v.y - v.x); c *= 1.0 - edge * 0.5;
  o = pre(clamp(c, 0.0, 1.0), max(src.a, s.a)); }
