// chromaber
uniform vec2 p_merkez; uniform float p_siddet, p_kirmiziKaym, p_yesilKaym, p_maviKaym, p_kenarYogu, p_alfaKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 r = toUnit(here()) - p_merkez; float L = length(boxU()) * 0.5; vec2 dir = r / max(L, 1.0); float k = mix(1.0, length(dir) * 1.4, p_kenarYogu / 100.0) * p_siddet * u_s;
  vec2 d = length(dir) > 1e-4 ? normalize(dir) : vec2(0.0); vec4 R = texPx(here() - d * k * p_kirmiziKaym), G = texPx(here() - d * k * p_yesilKaym), Bc = texPx(here() - d * k * p_maviKaym);
  o = vec4(R.r, G.g, Bc.b, p_alfaKoru > 0.5 ? s.a : max(R.a, max(G.a, Bc.a))); }
