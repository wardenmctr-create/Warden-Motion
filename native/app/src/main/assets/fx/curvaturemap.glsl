// curvaturemap
uniform vec3 c_icbukey, c_disbukey; uniform float p_olcumYari, p_notrEsik;
// Eğrilik: yarıçap içindeki alfa ortalaması (0.5 düz, >0.5 içbükey köşe, <0.5 dışbükey çıkıntı); yalnız kenar bandında
float avgA(vec2 p, float r) { float a = 0.0; for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 o2 = vec2(i, j) / 3.0; if (length(o2) > 1.0) continue; a += step(0.5, texPx(p + o2 * r).a); } return a / 29.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float r = max(p_olcumYari * u_s, 1.5); float e = length(alphaGrad(p, 1.0)); if (s.a <= 0.0 || e < 0.05) { o = s; return; }
  float k = (avgA(p, r) - 0.5) * 2.0; float th = p_notrEsik / 100.0; vec3 base = unpre(s); vec3 c = abs(k) < th ? base : (k > 0.0 ? c_icbukey : c_disbukey); float w = smoothstep(th, th + 0.15, abs(k));
  o = pre(mix(base, c, w), s.a); }
