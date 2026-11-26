// longshadow
uniform float p_uzunluk, p_aci, p_golgeOpak, p_uctaSolm, p_yalnizGolg; uniform vec3 c_golgeReng;
void main() {
  vec4 s = texture(u_tex, v_uv); float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)) * u_s;
  float L = p_uzunluk; float sh = 0.0; int N = int(clamp(L * u_s / 1.5, 4.0, 120.0));
  for (int i = 1; i <= 120; i++) { if (i > N) break; float t = float(i) / float(N); float aa = texPx(here() - d * L * t).a; sh = max(sh, aa * (1.0 - t * p_uctaSolm / 100.0)); }
  vec4 shc = vec4(c_golgeReng, 1.0) * sh * p_golgeOpak / 100.0;
  o = p_yalnizGolg > 0.5 ? shc * (1.0 - s.a) : overPre(s, shc);
}
