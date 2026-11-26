// confetti
GRADIENT(renkPale)
uniform float p_yogunluk, p_boyut, p_dususHizi, p_ruzgar, p_donmeHizi, p_sekil, p_tohum, p_dongu;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec4 acc = vec4(0.0); float cell = mix(70.0, 25.0, clamp(p_yogunluk / 400.0, 0.0, 1.0));
  vec2 p = q + B * 0.5 - vec2(p_ruzgar, p_dususHizi) * u_t; vec2 id = floor(p / cell);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum)); vec2 h2 = hash2(c + 7.0);
    vec2 cp = (c + h) * cell + vec2(sin(u_t * 2.0 + h2.x * 6.0) * 8.0, 0.0); float ang = u_t * p_donmeHizi * (h2.y - 0.5) * 2.0 + h.x * 360.0;
    vec2 r = rot2(-ang) * (p - cp); float flip = abs(cos(u_t * 4.0 + h.y * 6.0)); float sz = p_boyut * 0.5;
    float sh = p_sekil < 3.5 ? p_sekil : floor(h2.x * 3.0); float d = sh < 0.5 ? max(abs(r.x), abs(r.y) / max(flip, 0.15)) - sz : sh < 1.5 ? max(abs(r.x) - sz * 0.35, abs(r.y) / max(flip, 0.15) - sz * 1.2) : length(r * vec2(1.0, 1.0 / max(flip, 0.15))) - sz;
    float k = 1.0 - smoothstep(-0.6 / u_s, 0.6 / u_s, d); vec3 col = grad_renkPale(h2.x) * (0.75 + 0.25 * flip); acc = overPre(vec4(col, 1.0) * k, acc); }
  if (p_dongu < 0.5 && u_t > 3.0) acc *= clamp(1.0 - (u_t - 3.0), 0.0, 1.0);
  o = overPre(acc, s);
}
