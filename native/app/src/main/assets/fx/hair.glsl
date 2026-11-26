// hair
uniform float p_yogunluk, p_uzunluk, p_kalinlik, p_yon, p_rastgeleAci, p_ruzgar, p_tohum, p_kaynakReng; uniform vec3 c_kokReng, c_ucReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cell = max(sqrt(boxU().x * boxU().y / max(p_yogunluk, 1.0)), 2.0); vec4 acc = vec4(0.0);
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 id = floor(q / cell) + vec2(float(i), float(j)); vec2 h = hash2(id + seedf(p_tohum)); vec2 root = (id + h) * cell;
    vec4 rc = texU(root); if (rc.a < 0.5) continue; vec2 g = alphaGrad(fromUnit(root), 2.0); if (length(g) * 4.0 < 0.05 && p_yon > 900.0) continue;
    float a = radians(p_yon + (h.x - 0.5) * 2.0 * p_rastgeleAci) + sin(u_t * 2.0 + h.y * 6.0) * p_ruzgar / 100.0 * 0.4; vec2 dir = vec2(cos(a), sin(a)); float L = p_uzunluk * (0.6 + 0.4 * h.y);
    vec2 rel = q - root; float t = clamp(dot(rel, dir) / max(L, 1.0), 0.0, 1.0); float d = length(rel - dir * t * L); float w = p_kalinlik * 0.5 * (1.0 - t * 0.7);
    float m = (1.0 - smoothstep(w, w + 0.7 / u_s, d)) * step(0.0, dot(rel, dir)); vec3 col = mix(p_kaynakReng > 0.5 ? unpre(rc) * 0.7 : c_kokReng, p_kaynakReng > 0.5 ? unpre(rc) * 1.2 : c_ucReng, t); acc = max(acc, vec4(col, 1.0) * m); }
  o = overPre(acc, s);
}
