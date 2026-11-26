// snow
uniform float p_yogunluk, p_enKucuTane, p_enBuyuTane, p_dususHizi, p_ruzgar, p_sallanma, p_derinlik, p_tohum, p_alfayaKirp; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); float acc = 0.0;
  for (int l = 0; l < 3; l++) { float z = 1.0 - float(l) * 0.3 * p_derinlik / 100.0; float cell = mix(60.0, 25.0, clamp(p_yogunluk / 600.0, 0.0, 1.0)) / z;
    vec2 off = vec2(p_ruzgar, p_dususHizi) * u_t * z; vec2 p = q + B * 0.5 - off + float(l) * 37.0; vec2 id = floor(p / cell);
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(float(i), float(j)); vec2 h = hash2(c + seedf(p_tohum) + float(l) * 9.0);
      if (h.x > clamp(p_yogunluk / 300.0, 0.05, 1.0)) continue; vec2 cp = (c + h) * cell + vec2(sin(u_t * 1.5 + h.y * 6.0) * p_sallanma, 0.0);
      float r = mix(p_enKucuTane, p_enBuyuTane, h.y) * 0.5 * z; float d = length(p - cp); acc = max(acc, (1.0 - smoothstep(r * 0.4, r, d)) * mix(0.6, 1.0, z)); } }
  vec4 f = vec4(c_renk, 1.0) * acc; if (p_alfayaKirp > 0.5) f *= s.a; o = overPre(f, s);
}
