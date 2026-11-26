// fire
uniform vec2 p_alevKayn; uniform float p_yuksekli, p_genislik, p_yogunluk, p_hiz, p_turbulan, p_tohum, p_alfayaKirp; uniform vec3 c_tabanReng, c_ucReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 r = toUnit(here()) - p_alevKayn; float h = max(p_yuksekli, 1.0), w = max(p_genislik, 1.0);
  float y = -r.y / h; float x = r.x / (w * 0.5); vec2 p = vec2(x * 1.5, y * 2.0 - u_t * p_hiz) + seedf(p_tohum);
  float n = fbm(p * 2.0, 4.0) * p_turbulan / 100.0; float shape = 1.0 - smoothstep(0.0, 1.0, abs(x + n * 0.6) / max(1.0 - y * 0.85, 0.05));
  float f = shape * smoothstep(-0.05, 0.05, y) * (1.0 - smoothstep(0.6, 1.1, y + n * 0.5)) * (0.7 + 0.6 * (fbm(p * 3.0, 3.0) * 0.5 + 0.5));
  f = clamp(f * p_yogunluk / 100.0 * 1.8, 0.0, 1.0); vec3 col = mix(c_ucReng, c_tabanReng, smoothstep(0.2, 0.9, f)) + vec3(1.0, 0.95, 0.8) * smoothstep(0.8, 1.0, f) * 0.6;
  vec4 fc = vec4(col, 1.0) * f; if (p_alfayaKirp > 0.5) fc *= s.a; o = vec4(s.rgb * (1.0 - fc.a) + fc.rgb, max(s.a, fc.a));
}
