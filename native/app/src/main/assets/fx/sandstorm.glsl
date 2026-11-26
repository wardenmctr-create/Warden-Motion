// sandstorm
uniform float p_yogunluk, p_kumBuyu, p_ruzgarHizi, p_ruzgarYonu, p_turbulan, p_tozTaba, p_gorusAzal, p_hareketBula, p_degiskenRuzg, p_ruzgarDegiSikl, p_tohum; uniform vec3 c_kumReng;
void main() { vec4 s = texture(u_tex, v_uv); float gust = p_degiskenRuzg > 0.5 ? 0.6 + 0.8 * vnoise(vec2(u_t * p_ruzgarDegiSikl, 5.0)) : 1.0; vec2 dir = vec2(cos(radians(p_ruzgarYonu)), sin(radians(p_ruzgarYonu)));
  vec2 q = toUnit(here()); vec2 p = rot2(-p_ruzgarYonu) * q; float sd = seedf(p_tohum); float off = u_t * p_ruzgarHizi * gust;
  float haze = fbm01((p - vec2(off * 0.3, 0.0)) * 0.006 + sd, 4.0); haze = mix(haze, fbm01((p - vec2(off * 0.3, 0.0)) * 0.006 + vec2(haze * p_turbulan / 30.0), 4.0), 0.5);
  float grains = 0.0; float gs = max(p_kumBuyu, 0.5); vec2 g = vec2((p.x - off) / (gs * (1.0 + p_hareketBula / 10.0)), p.y / gs); vec2 id = floor(g);
  float h = hash1(id + sd); grains = step(1.0 - p_yogunluk / 100.0 * 0.35, h) * (1.0 - smoothstep(0.3, 0.5, abs(fract(g.y) - 0.5)));
  float ground = smoothstep(boxU().y * (0.5 - p_tozTaba / 100.0), boxU().y * 0.5, q.y) * p_tozTaba / 100.0;
  float fog = clamp(haze * p_yogunluk / 100.0 * 1.2 + ground, 0.0, 1.0); vec4 c = s; c.rgb = mix(c.rgb, c_kumReng * c.a, p_gorusAzal / 100.0 * c.a);
  c = overPre(vec4(c_kumReng, 1.0) * fog * 0.75, c); c = overPre(vec4(c_kumReng * 1.3, 1.0) * grains * 0.8, c); o = c; }
