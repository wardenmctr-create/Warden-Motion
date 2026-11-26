// scatterpx
uniform float p_sacilmaMesa, p_yogunluk, p_eksen, p_tohum, p_zamanaBagl;
void main() {
  vec2 px = here(); float tk = p_zamanaBagl > 0.5 ? floor(u_t * 24.0) : 0.0;
  vec2 r = hash2(floor(px) + seedf(p_tohum) + tk * 1.7) * 2.0 - 1.0; if (p_eksen > 0.5 && p_eksen < 1.5) r.y = 0.0; if (p_eksen > 1.5) r.x = 0.0;
  float on = step(hash1(floor(px) + 9.1 + tk), p_yogunluk / 100.0);
  o = texPx(px + r * p_sacilmaMesa * u_s * on);
}
