// magnifybg
uniform sampler2D s_bgsrc; uniform float p_bgsrcOn; uniform float p_buyutme, p_kenarYumu, p_sinir, p_alfaylaKirp; uniform vec2 p_merkez, p_kayma;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 c = boxUV(fromUnit(p_merkez)); vec2 sb = c + (b - c) / max(p_buyutme / 100.0, 0.1) - p_kayma * u_s / u_box.zw;
  if (p_sinir > 1.5) sb = 1.0 - abs(1.0 - mod(sb, 2.0)); else if (p_sinir > 0.5) sb = clamp(sb, 0.0, 1.0);
  vec4 bg = p_bgsrcOn > 0.5 ? texture(s_bgsrc, sb) : texPx(boxPx(sb)); if (p_sinir < 0.5 && (any(lessThan(sb, vec2(0.0))) || any(greaterThan(sb, vec2(1.0))))) bg = vec4(0.0);
  o = p_alfaylaKirp > 0.5 ? bg * s.a : bg; }
