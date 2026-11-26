// massflow
uniform sampler2D s_alanMask; uniform vec2 p_giris, p_cikis; uniform float p_alanMaskOn, p_akis, p_viskozit;
// Giriş → çıkış arasında taşınan yoğunluk: akım çizgileri boyunca hareket eden şeritler; maske içinde kalır
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float m = p_alanMaskOn > 0.5 ? texture(s_alanMask, boxUV(here())).a : s.a; if (m <= 0.0) { o = s; return; }
  vec2 ab = p_cikis - p_giris; float L = max(length(ab), 1.0); vec2 t1 = ab / L, nr = vec2(-t1.y, t1.x); float u = dot(q - p_giris, t1) / L; float v = dot(q - p_giris, nr);
  float spread = L * (0.15 + 0.35 * sin(clamp(u, 0.0, 1.0) * 3.14159)); float bend = fbm(vec2(u * 3.0, v / spread * 2.0), 3.0) * (1.0 - p_viskozit / 100.0) * spread * 0.4;
  float dens = exp(-pow((v + bend) / spread, 2.0)) * smoothstep(-0.05, 0.05, u) * smoothstep(1.05, 0.95, u);
  float stripes = 0.5 + 0.5 * sin((u * L - u_t * p_akis) / 14.0 + fbm(vec2(v * 0.05, u * 4.0), 2.0) * 3.0);
  float a = dens * (0.35 + 0.65 * stripes) * m; o = vec4(mix(s.rgb, vec3(0.3, 0.75, 1.0) * max(s.a, a), a * 0.85), max(s.a, a)); }
