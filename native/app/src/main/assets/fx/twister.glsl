// twister
uniform vec2 p_merkez; uniform float p_ilerleme, p_bukulmeAcis, p_eksen, p_perspekt, p_golge, p_ters; uniform vec3 c_arkaYuzReng;
void main() { vec2 q = toUnit(here()); vec2 B = boxU(); float pr = p_ilerleme / 100.0; if (p_ters > 0.5) pr = 1.0 - pr; vec2 ax = vec2(cos(radians(p_eksen)), sin(radians(p_eksen))); vec2 nx = vec2(-ax.y, ax.x);
  vec2 r = q - p_merkez; float along = dot(r, ax); float across = dot(r, nx); float L = abs(dot(B, abs(ax))); float ang = radians(p_bukulmeAcis) * pr * 2.0 * (0.5 + along / max(L, 1.0)) + PI * pr;
  float c = cos(ang); if (abs(c) < 0.02) { o = vec4(0.0); return; } float W = abs(dot(B, abs(nx))) * 0.5; float src_ = across / c * (1.0 + sin(ang) * p_perspekt / 100.0 * 0.2 * across / max(W, 1.0));
  if (abs(src_) > W) { o = vec4(0.0); return; } vec4 col = texU(p_merkez + ax * along + nx * src_); if (c < 0.0) col = vec4(c_arkaYuzReng, 1.0) * col.a; col.rgb *= 1.0 - (1.0 - abs(c)) * p_golge / 100.0; o = col; }
