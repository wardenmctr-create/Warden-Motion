// flowwarp
uniform sampler2D s_vektorHari; uniform float p_vektorHariOn, p_adim, p_akisGucu;
void main() { if (p_vektorHariOn < 0.5) { o = texture(u_tex, v_uv); return; } vec2 q = toUnit(here()); int N = int(clamp(p_adim, 1.0, 64.0)); float st = p_akisGucu / float(N);
  for (int i = 0; i < 64; i++) { if (i >= N) break; vec2 v = unpre(texture(s_vektorHari, clamp(boxUV(fromUnit(q)), 0.0, 1.0))).rg * 2.0 - 1.0; q -= v * st; } o = texU(q); }
