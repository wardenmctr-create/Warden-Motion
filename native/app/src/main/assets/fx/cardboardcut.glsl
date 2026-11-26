// cardboardcut
uniform vec3 c_icRenk; uniform float p_kartonKali, p_olukAral, p_kesitGoru;
// Kesik kenar bandında oluklu karton kesiti: iki düz kâğıt arasında dalgalı oluk
void main() { vec4 s = texture(u_tex, v_uv); if (s.a < 0.5) { o = s; return; } vec2 p = here(); float T = p_kartonKali * u_s; float d = innerDist(p, T * 1.2); if (d > T) { o = s; return; }
  vec2 q = toUnit(p); float along = atan(q.y, q.x) * length(q); float y = d / T; float wave = 0.5 + 0.38 * sin(along / max(p_olukAral, 0.5) * 3.14159);
  float liner = step(y, 0.12) + step(0.88, y); float flute = 1.0 - smoothstep(0.03, 0.09, abs(y - wave)); float cav = step(0.12, y) * step(y, 0.88) * (1.0 - flute);
  vec3 c = liner > 0.0 ? c_icRenk * 1.08 : (flute > 0.0 ? c_icRenk * 0.92 : c_icRenk * 0.45); o = mix(s, pre(c, 1.0), p_kesitGoru / 100.0 * (1.0 - cav * 0.0)); }
