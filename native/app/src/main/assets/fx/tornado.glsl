// tornado
uniform vec2 p_merkez; uniform float p_gorunum, p_disYari, p_gozYari, p_yuksekli, p_donusHizi, p_sarmalKolSayi, p_sarmalSiki, p_bulutYogu, p_turbulan, p_opaklik, p_tohum; uniform vec3 c_bulutReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float sd = seedf(p_tohum); float d = 0.0; vec3 col = c_bulutReng;
  if (p_gorunum < 0.5) { float r = length(q); float a = atan(q.y, q.x) + u_t * radians(p_donusHizi) * 0.3; float lr = log(max(r, 1.0)); float arms = max(floor(p_sarmalKolSayi), 1.0);
    float sp = sin(a * arms + lr * p_sarmalSiki / 10.0 * arms); float f = fbm(vec2(a * 2.0, lr * 4.0) + sd, 5.0) * (1.0 + p_turbulan / 100.0) - p_turbulan / 200.0;
    d = smoothstep(0.1, 0.9, (sp * 0.5 + 0.5) * 0.6 + f * 0.7) * smoothstep(p_disYari, p_disYari * 0.5, r) * smoothstep(p_gozYari * 0.6, p_gozYari * 1.4, r) * p_bulutYogu / 100.0 * 1.4;
    col = mix(c_bulutReng * 0.6, vec3(1.0), smoothstep(0.3, 0.9, f)); }
  else { float H = max(p_yuksekli, 10.0); float y = clamp((q.y + H * 0.5) / H, 0.0, 1.0); float w = mix(p_disYari, p_gozYari, pow(y, 0.6)) * (p_gorunum > 1.5 ? 0.6 : 1.0);
    float sway = sin(y * 3.0 + u_t * 1.3) * w * 0.25; float x = (q.x - sway) / max(w, 1.0); float inside = 1.0 - smoothstep(0.7, 1.0, abs(x));
    float a = asin(clamp(x, -1.0, 1.0)) + u_t * radians(p_donusHizi); float f = fbm(vec2(a * 2.0, y * 8.0 - u_t * 0.5) + sd, 4.0);
    d = inside * step(-H * 0.5, q.y) * step(q.y, H * 0.5) * smoothstep(0.2, 0.7, f * (1.0 + p_turbulan / 100.0)) * p_bulutYogu / 100.0 * 1.5; col = mix(c_bulutReng * 0.7, c_bulutReng * 1.2, f);
    if (p_gorunum > 1.5) { float dust = smoothstep(H * 0.5, H * 0.3, q.y) * smoothstep(p_disYari * 1.5, 0.0, abs(q.x)) * fbm(q * 0.03 + u_t * 0.4, 3.0); d = max(d, dust); } }
  o = overPre(vec4(col, 1.0) * clamp(d, 0.0, 1.0) * p_opaklik / 100.0, s); }
