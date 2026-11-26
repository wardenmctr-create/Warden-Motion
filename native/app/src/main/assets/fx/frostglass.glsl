// frostglass
uniform float p_donmaMikt, p_kristalBuyu, p_kristalYogu, p_dallanma, p_buzKali, p_bulanikl, p_isikKiri, p_donmaBasl, p_donmaAnim, p_donmaIler, p_tohum; uniform vec3 c_buzReng, c_kristalReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 b = boxUV(here()); float sd = seedf(p_tohum);
  float start = p_donmaBasl < 0.5 ? 1.0 - min(min(b.x, 1.0 - b.x), min(b.y, 1.0 - b.y)) * 2.0 : p_donmaBasl < 1.5 ? 1.0 - length(b - 0.5) * 1.6 : fbm01(q * 0.01 + sd, 3.0) * 1.4;
  float prog = (p_donmaAnim > 0.5 ? p_donmaIler : 100.0) / 100.0 * p_donmaMikt / 100.0; float f = smoothstep(1.0 - prog * 1.3, 1.0 - prog * 1.3 + 0.25, start + fbm01(q * 0.02 + sd, 4.0) * 0.4);
  float cs = max(p_kristalBuyu, 1.0); vec4 v = voronoi(q / cs + sd); float edges = 1.0 - smoothstep(0.0, 0.06 + p_dallanma / 2000.0, v.y - v.x);
  float dend = 0.0; for (int k = 0; k < 3; k++) { vec4 w = voronoi(q / (cs * (0.5 - float(k) * 0.12)) + sd + float(k) * 3.0); dend = max(dend, (1.0 - smoothstep(0.0, 0.05, w.y - w.x)) * p_dallanma / 100.0); }
  float cr = clamp(edges + dend * p_kristalYogu / 100.0, 0.0, 1.0) * f;
  vec2 rf = vec2(fbm01(q * 0.05 + 1.0, 3.0), fbm01(q * 0.05 + 7.0, 3.0)) - 0.5; vec4 bl = vec4(0.0); float br = p_bulanikl * f * u_s;
  for (int i = 0; i < 8; i++) { float a = float(i) * TAU / 8.0; bl += texPx(here() + rf * p_isikKiri * u_s + vec2(cos(a), sin(a)) * br); } bl /= 8.0;
  vec4 c = mix(s, bl, f); c.rgb = mix(c.rgb, c_buzReng * c.a, f * p_buzKali / 100.0 * 0.5); c = overPre(vec4(c_kristalReng, 1.0) * cr * 0.8, c); o = c; }
