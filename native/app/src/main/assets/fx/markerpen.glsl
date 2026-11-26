// markerpen
INCLUDE(_mat)
uniform float p_ucGeni, p_darbeUzun, p_darbeYonu, p_yonDuze, p_murekkepYogu, p_ustUsteBinm, p_renkSayi, p_kenarKoru, p_kagitDoku, p_darbelerNesnSabi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float W = max(p_ucGeni, 1.0), L = max(p_darbeUzun, 2.0); vec3 acc = vec3(1.0); float cov = 0.0;
  for (int pass = 0; pass < 2; pass++) { float ang = p_darbeYonu + float(pass) * (p_ustUsteBinm > 0.0 ? 90.0 : 0.0); vec2 r = rot2(-ang) * q; vec2 g = vec2(r.x / L, r.y / W);
    for (int j = -1; j <= 1; j++) { vec2 id = vec2(floor(g.x + hash1(vec2(floor(g.y) + float(j), float(pass))) ), floor(g.y) + float(j)); vec2 h = hash2(id + float(pass) * 7.0);
      float a2 = (h.x - 0.5) * p_yonDuze; vec2 ctr = vec2(id.x + 0.5, id.y + 0.5 + (h.y - 0.5) * 0.5); vec2 lq = rot2(-a2) * ((g - ctr) * vec2(L, W)); float m = (1.0 - smoothstep(W * 0.45, W * 0.55, abs(lq.y))) * (1.0 - smoothstep(L * 0.5, L * 0.5 + W * 0.3, abs(lq.x)));
      vec2 sp = rot2(ang) * vec2(ctr.x * L, ctr.y * W); vec4 sc = texU(sp); if (pass == 1 && hash1(id + 3.0) > p_ustUsteBinm / 100.0) m = 0.0;
      vec3 col = sc.a > 0.0 ? sc.rgb / sc.a : vec3(1.0); float k = max(p_renkSayi, 2.0); col = floor(col * pow(k, 1.0 / 3.0) + 0.5) / pow(k, 1.0 / 3.0);
      float edge = 1.0 + 0.25 * smoothstep(W * 0.3, W * 0.5, abs(lq.y)); acc *= mix(vec3(1.0), col / edge, m * p_murekkepYogu / 100.0 * sc.a); cov = max(cov, m * sc.a); } }
  vec3 paper = p_kagitDoku > 0.0 ? mix(vec3(1.0), matSample(1, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(luma(matBase(1)), 0.1), p_kagitDoku / 100.0) : vec3(1.0);
  vec3 c = acc * paper; float e = smoothstep(0.2, 0.6, sobel(here(), u_s)) * p_kenarKoru / 100.0; c = mix(c, c * 0.35, e * s.a); o = pre(clamp(c, 0.0, 1.0), max(s.a, 0.0)); }
