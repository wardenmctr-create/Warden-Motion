// twotargetzoom
uniform float p_kenarPayi, p_azamiZoom, p_dvN; uniform float p_dv[8];
void main() { vec2 b = boxUV(here()); vec2 A = p_dvN >= 4.0 ? vec2(p_dv[0], p_dv[1]) : vec2(0.35, 0.45), B = p_dvN >= 4.0 ? vec2(p_dv[2], p_dv[3]) : vec2(0.65, 0.55); vec2 mn = min(A, B), mx = max(A, B); vec2 sz = (mx - mn) * (1.0 + p_kenarPayi / 50.0) + 0.05;
  float z = clamp(1.0 / max(sz.x, sz.y), 1.0, p_azamiZoom / 100.0); vec2 c = (mn + mx) * 0.5; vec2 src = c + (b - 0.5) / z; o = texPx(boxPx(src)); }
