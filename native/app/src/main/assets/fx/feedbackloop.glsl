// feedbackloop
INCLUDE(_hist)
uniform float p_geriBesl, p_olcek, p_donus, p_birlesti;
void main() { vec4 s = texture(u_tex, v_uv); float N = histN(); if (N < 2.0) { o = s; return; } vec4 acc = s; float w = 1.0; vec2 q = toUnit(here());
  for (int k = 1; k < 16; k++) { if (float(k) >= N) break; w *= p_geriBesl / 100.0; float sc = pow(p_olcek / 100.0, float(k)); vec2 l = rot2(-p_donus * float(k)) * q / max(sc, 0.01); vec4 h = hist(float(k), fromUnit(l) / u_res) * w;
    acc = p_birlesti < 0.5 ? overPre(acc, h) : p_birlesti < 1.5 ? acc + h : vec4(screenB(acc.rgb, h.rgb), max(acc.a, h.a)); }
  o = clamp(acc, 0.0, 1.0); }
