// bubbles
uniform float p_yogunluk, p_enKucuBoyu, p_enBuyuBoyu, p_yukselmeHizi, p_sallanma, p_yansima, p_saydamli, p_tohum; uniform vec3 c_kenarReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec4 acc = vec4(0.0); float cell = mix(90.0, 35.0, clamp(p_yogunluk / 200.0, 0.0, 1.0));
  vec2 p = q + B * 0.5 + vec2(0.0, p_yukselmeHizi * u_t); vec2 id = floor(p / cell);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum)); if (h.x > clamp(p_yogunluk / 80.0, 0.1, 1.0)) continue;
    vec2 cp = (c + h) * cell + vec2(sin(u_t * 1.3 + h.y * 6.0) * p_sallanma, 0.0); float r = mix(p_enKucuBoyu, p_enBuyuBoyu, h.y); vec2 rel = p - cp; float d = length(rel);
    if (d > r) continue; float rim = smoothstep(r * 0.75, r, d); vec3 ir = hsv2rgb(vec3(fract(atan(rel.y, rel.x) / TAU + u_t * 0.1), 0.35, 1.0));
    float spec = (1.0 - smoothstep(0.0, r * 0.25, length(rel - vec2(-0.4, -0.4) * r))) * p_yansima / 100.0;
    float a = (rim * 0.8 + (1.0 - p_saydamli / 100.0) * 0.3) ; vec3 col = mix(c_kenarReng, ir, 0.4) * a + vec3(spec); acc = overPre(vec4(col, clamp(a + spec, 0.0, 1.0)), acc); }
  o = overPre(acc, s);
}
