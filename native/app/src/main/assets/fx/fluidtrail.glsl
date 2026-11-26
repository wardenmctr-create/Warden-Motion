// fluidtrail
INCLUDE(_hist)
uniform sampler2D s_izKayn; uniform float p_izKaynOn, p_birikim, p_sonme, p_akis, p_yayilma;
// Geçmiş karelerde katmanın kapladığı yerler yoğunluk izi bırakır; iz yaşla söner, akışla yukarı taşınır ve yayılır
void main() { vec4 s = texture(u_tex, v_uv); float n = histN(); if (n < 2.0) { o = s; return; } vec4 acc = vec4(0.0);
  for (int i = 1; i < 16; i++) { if (float(i) >= n) break; float age = float(i) / (n - 1.0); vec2 sh = vec2(0.0, p_akis * age * u_s) / u_res; float sp = p_yayilma * u_s * age / u_res.x;
    vec4 c = (hist(float(i), v_uv + sh) + hist(float(i), v_uv + sh + vec2(sp, 0.0)) + hist(float(i), v_uv + sh - vec2(sp, 0.0))) / 3.0; acc += c * exp(-age * 3.0 / max(p_sonme, 0.01)) ; }
  acc *= p_birikim / 100.0 * 0.6; acc = min(acc, vec4(1.0)); o = overPre(s, acc); }
