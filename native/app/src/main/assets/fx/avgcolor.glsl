// avgcolor
uniform sampler2D s_kaynak; uniform float p_kaynakOn, p_ortalamaOrta; uniform vec2 p_ornekAlan, p_ornekAlanBoyu;
vec4 smp(vec2 uv) { return p_kaynakOn > 0.5 ? texture(s_kaynak, clamp(uv, 0.0, 1.0)) : texPx(boxPx(clamp(uv, 0.0, 1.0))); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 c = p_ornekAlan / 100.0; vec2 sz = p_ornekAlanBoyu / 100.0; vec3 acc = vec3(0.0); float n = 0.0; float vs[25]; vec3 cs[25];
  for (int j = 0; j < 5; j++) for (int i = 0; i < 5; i++) { vec4 v = smp(c + (vec2(i, j) / 4.0 - 0.5) * sz); vec3 u = unpre(v); acc += u * v.a; n += v.a; cs[j * 5 + i] = u; vs[j * 5 + i] = luma(u) + (v.a < 0.1 ? 9.0 : 0.0); }
  vec3 col = acc / max(n, 1e-3);
  if (p_ortalamaOrta > 0.5) { for (int i = 0; i < 13; i++) for (int j = i + 1; j < 25; j++) if (vs[j] < vs[i]) { float t = vs[i]; vs[i] = vs[j]; vs[j] = t; vec3 tc = cs[i]; cs[i] = cs[j]; cs[j] = tc; } col = cs[12]; }
  o = pre(col, s.a); }
