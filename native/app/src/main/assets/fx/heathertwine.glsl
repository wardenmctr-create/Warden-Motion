// heathertwine
uniform sampler2D s_yol; uniform vec3 c_ikinciRenk; uniform float p_yolOn, p_lif, p_toplamKali, p_renkKari;
// Şerit/kontur içinde kenara paralel lifler; lif başına renk (ana renk ya da ikinci renk), akış boyunca hafif titreşim
float A(vec2 px) { return p_yolOn > 0.5 ? texture(s_yol, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (A(p) < 0.5) { o = s; return; } float T = p_toplamKali * u_s; float d = 0.0;
  for (int i = 0; i < 12; i++) { float a = float(i) / 12.0 * TAU; float r = T; for (int k = 1; k <= 16; k++) { float rr = float(k) / 16.0 * T; if (A(p + vec2(cos(a), sin(a)) * rr) < 0.5) { r = rr; break; } } d = i == 0 ? r : min(d, r); }
  vec2 q = toUnit(p); float along = atan(q.y, q.x) * length(q); float wob = sin(along * 0.2) * 0.3; float N = clamp(floor(p_lif), 2.0, 32.0); float idx = floor(d / max(T, 1.0) * N + wob);
  float h = hash1(vec2(idx, 2.3)); vec3 base = p_yolOn > 0.5 ? vec3(0.85, 0.3, 0.25) : unpre(s); vec3 c = h < p_renkKari / 100.0 ? c_ikinciRenk : base;
  float sep = abs(fract(d / max(T, 1.0) * N + wob) - 0.5) * 2.0; c *= 0.82 + 0.18 * (1.0 - sep * sep); o = d >= T * 0.999 ? s : pre(c, 1.0); }
