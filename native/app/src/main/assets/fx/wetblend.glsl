// wetblend
uniform sampler2D s_digerBoya; uniform float p_digerBoyaOn, p_karisimDeri, p_islaklik, p_akis, p_kurutma;
// İki boyanın temas sınırında pigment karışımı: sınıra yakın pikseller komşu boyanın rengini akış yönünde sürüklenmiş izlerle alır; zamanla kurur
vec4 other(vec2 px) { return p_digerBoyaOn > 0.5 ? texture(s_digerBoya, boxUV(px)) : texPx(px + vec2(9.0 * u_s, 0.0)) * step(0.0, 0.0); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float D = max(p_karisimDeri * u_s, 1.0); float wet = p_islaklik / 100.0 * (1.0 - exp(-u_t / max(p_kurutma, 0.05)) * 0.0) * exp(-u_t / max(p_kurutma * 4.0, 0.1) * 0.15);
  vec2 flow = vec2(fbm(p / (D * 2.0) + u_t * 0.1, 3.0), fbm(p / (D * 2.0) + 5.0, 3.0)) * p_akis * u_s; vec3 mine = unpre(s); vec3 acc = vec3(0.0); float w = 0.0;
  for (int i = 0; i < 8; i++) { float a = float(i) / 8.0 * TAU; vec2 q = p + flow + vec2(cos(a), sin(a)) * D; vec4 c = p_digerBoyaOn > 0.5 ? other(q) : texPx(q); if (c.a < 0.3) continue; vec3 cc = unpre(c); float diff = length(cc - mine); if (diff < 0.12) continue; acc += cc; w += 1.0; }
  if (w <= 0.0 || s.a <= 0.0) { o = s; return; } vec3 mixc = sqrt(mine * (acc / w)); float k = wet * clamp(w / 4.0, 0.0, 1.0) * 0.8; o = pre(mix(mine, mixc, k), s.a); }
