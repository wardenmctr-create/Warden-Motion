// coderain
uniform float p_sutunAral, p_yaziBoyu, p_hiz, p_izUzun, p_tohum; uniform vec3 c_renk, c_basRenk;
float glyph(vec2 f, float id) { vec2 g = floor(f * vec2(3.0, 5.0)); return step(0.45, hash1(g + id * 7.3)) * step(0.1, f.x) * step(f.x, 0.9) * step(0.05, f.y) * step(f.y, 0.95); }
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) + boxU() * 0.5; float cw = max(p_sutunAral, 2.0), ch = max(p_yaziBoyu, 2.0);
  float col = floor(q.x / cw); float sd = seedf(p_tohum); float sp = p_hiz * (0.6 + hash1(vec2(col, sd)) * 0.8);
  float head = fract(hash1(vec2(col, sd + 1.0)) + u_t * sp / max(boxU().y + ch * p_izUzun, 1.0)) * (boxU().y + ch * p_izUzun);
  float row = floor(q.y / ch); float dist = (head - q.y) / ch;
  float k = dist >= 0.0 && dist < p_izUzun ? 1.0 - dist / p_izUzun : 0.0;
  float gid = floor(hash1(vec2(col, row)) * 50.0 + floor(u_t * 6.0 * hash1(vec2(row, col))));
  float g = glyph(fract(q / vec2(cw, ch)) * vec2(cw / ch, 1.0) * vec2(ch / cw, 1.0), gid);
  vec3 c = mix(c_renk, c_basRenk, step(dist, 1.0) * step(0.0, dist)) * g * k;
  o = overPre(vec4(c, max(c.r, max(c.g, c.b))), s);
}
