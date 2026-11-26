// matchgrain
uniform sampler2D s_referansKatm; uniform vec2 p_ornekAlan; uniform float p_referansKatmOn, p_ornekBoyu, p_grenGucu, p_grenBoyu, p_renkliGren, p_zamansalDegi;
float lumR(vec2 uv) { vec4 c = p_referansKatmOn > 0.5 ? texture(s_referansKatm, uv) : texture(u_tex, uv); return luma(unpre(c)); }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  // referansın ince ayrıntı (yüksek geçiren) sapması: Örnek Alan noktası çevresinde, Örnek Boyu genişliğinde 16 nokta
  vec2 c0 = fromUnit(p_ornekAlan) / u_res; vec2 ext = vec2(max(p_ornekBoyu, 2.0) * u_s * 0.5) / u_res; vec2 px = 1.0 / u_res; float acc = 0.0;
  for (int j = 0; j < 4; j++) for (int i = 0; i < 4; i++) { vec2 uv = c0 + ext * (vec2(float(i), float(j)) / 1.5 - 1.0);
    float hp = lumR(uv) - 0.25 * (lumR(uv + vec2(px.x, 0.0)) + lumR(uv - vec2(px.x, 0.0)) + lumR(uv + vec2(0.0, px.y)) + lumR(uv - vec2(0.0, px.y))); acc += hp * hp; }
  float sd = sqrt(acc / 16.0) * 1.6 + 0.004;
  float fr = p_zamansalDegi > 0.5 ? floor(u_t * 24.0) : 0.0; vec2 g = floor(here() / max(p_grenBoyu * u_s, 1.0)) + fr * 17.31;
  vec3 nz = p_renkliGren > 0.5 ? vec3(hash1(g), hash1(g + 3.7), hash1(g + 9.1)) - 0.5 : vec3(hash1(g) - 0.5);
  vec3 rgb = clamp(unpre(s) + nz * sd * 3.4 * p_grenGucu / 100.0, 0.0, 1.0); o = pre(rgb, s.a); }
