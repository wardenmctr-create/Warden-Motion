// waveworld
uniform vec2 p_kaynak; uniform float p_dalgaYuks, p_dalgaBoyu, p_hiz, p_dalgaBici, p_yon, p_sonum, p_kenar;
void main() { vec2 q = toUnit(here()); vec2 r = q - p_kaynak; float d = length(r); float wl = max(p_dalgaBoyu, 1.0); vec2 disp;
  if (p_dalgaBici < 0.5) disp = (d > 0.01 ? r / d : vec2(0.0)) * sin(d / wl * TAU - u_t * p_hiz * TAU) * exp(-d / (length(boxU()) * 0.5) * p_sonum / 50.0);
  else if (p_dalgaBici < 1.5) { vec2 dir = vec2(cos(radians(p_yon)), sin(radians(p_yon))); disp = dir * sin(dot(q, dir) / wl * TAU - u_t * p_hiz * TAU); }
  else disp = vec2(fbm(q / wl + u_t * p_hiz * 0.3, 3.0), fbm(q / wl + 4.0 - u_t * p_hiz * 0.3, 3.0));
  o = texEdge(fromUnit(q + disp * p_dalgaYuks), p_kenar < 0.5 ? 0.0 : p_kenar < 1.5 ? 3.0 : 1.0); }
