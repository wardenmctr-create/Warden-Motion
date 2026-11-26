// capillary
uniform vec2 p_merkez; uniform float p_cizgi, p_bukulme, p_icYari, p_kalinlik;
// Dış çemberden içe uzanan, yarıçapla bükülen ince eğriler: θ(r) = θi + bükülme·(1 − r/R)²
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float R = min(boxU().x, boxU().y) * 0.48; float r = length(q); if (r > R || r < p_icYari) { o = s; return; }
  float N = max(floor(p_cizgi), 4.0); float bend = radians(p_bukulme) * pow(1.0 - r / R, 2.0) * 3.0; float th = atan(q.y, q.x) - bend; float k = th / 6.2832 * N; float dAng = abs(fract(k) - 0.5) * 6.2832 / N;
  float d = dAng * r; float v = (1.0 - smoothstep(p_kalinlik * 0.5 - 0.6 / u_s, p_kalinlik * 0.5 + 0.6 / u_s, d)) * smoothstep(p_icYari, p_icYari + 6.0, r); o = overPre(vec4(0.95, 0.9, 0.8, 1.0) * v, s); }
