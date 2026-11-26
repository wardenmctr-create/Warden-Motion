// fireworks
GRADIENT(renkler)
uniform vec2 p_patlamaMerk; uniform float p_parcacikSayi, p_yayilma, p_omur, p_yercekim, p_izUzun, p_patlamaAral, p_tohum;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float per = max(p_patlamaAral, 0.2); vec3 acc = vec3(0.0);
  for (int b = 0; b < 3; b++) { float tb = u_t - float(b) * per * 0.33; float k = floor(tb / per); float lt = tb - k * per; if (lt > p_omur || tb < 0.0) continue;
    float sd = seedf(p_tohum) + k * 7.0 + float(b) * 13.0; vec2 C = p_patlamaMerk + (hash2(vec2(sd, 1.0)) - 0.5) * boxU() * 0.5 * step(0.5, float(b));
    vec3 col = palc_renkler(int(hash1(vec2(sd, 3.0)) * float(paln_renkler())) % paln_renkler()); float life = lt / max(p_omur, 0.05);
    int N = int(clamp(p_parcacikSayi, 10.0, 160.0));
    for (int i = 0; i < 160; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), sd)); float a = h.x * TAU; float sp = sqrt(h.y);
      vec2 pos = C + vec2(cos(a), sin(a)) * p_yayilma * sp * (1.0 - pow(1.0 - min(life * 1.5, 1.0), 3.0)) + vec2(0.0, p_yercekim * 0.5 * lt * lt);
      float d = length(q - pos); acc += col * (1.0 - life) * (exp(-d * d / 4.0) * 1.2 + exp(-d / max(p_izUzun * 0.15, 0.5)) * 0.08); } }
  float a = clamp(max(acc.r, max(acc.g, acc.b)), 0.0, 1.0);
  o = vec4(min(s.rgb + acc, vec3(1.0)), max(s.a, a));
}
