// vegas
uniform float p_noktaSayi, p_noktaBoyu, p_faz, p_hiz, p_bosluk, p_hale, p_tersYon; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU() * 0.5;
  // kutunun çevresi boyunca konum
  vec2 e = B - abs(q); float per = 4.0 * (B.x + B.y);
  float t; if (e.x < e.y) t = q.x > 0.0 ? 2.0 * B.x + (q.y + B.y) : 4.0 * B.x + 2.0 * B.y + (B.y - q.y); else t = q.y < 0.0 ? (q.x + B.x) : 2.0 * B.x + 2.0 * B.y + (B.x - q.x);
  t = t / per; float n = max(2.0, floor(p_noktaSayi));
  float ph = t * n - (u_t * p_hiz * (p_tersYon > 0.5 ? -1.0 : 1.0)) * n * 0.2 - p_faz / 100.0 * n;
  float id = floor(ph); float on = step(p_bosluk / 100.0, fract(id * 0.37 + u_t * p_hiz));
  float sp = per / n; float dAlong = (fract(ph) - 0.5) * sp; float dPerp = min(e.x, e.y) - p_noktaBoyu;
  float d = length(vec2(dAlong, dPerp)); float r = max(p_noktaBoyu * 0.5, 0.5);
  float core = (1.0 - smoothstep(r - 0.5, r + 0.5, d)) * on; float halo = exp(-max(d - r, 0.0) / max(p_hale * 0.4, 0.5)) * on * 0.6;
  vec4 L = vec4(mix(c_renk, vec3(1.0), core * 0.5), 1.0) * clamp(core + halo, 0.0, 1.0);
  o = overPre(L, s);
}
