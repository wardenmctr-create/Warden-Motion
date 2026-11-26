// stackarea
INCLUDE(_chart)
uniform float p_cizimIler; uniform vec3 c_seriler;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); b.y = 1.0 - b.y; float R = dR(), C = dC(); float x = b.x * (R - 1.0); float r0 = floor(x), f = x - r0; if (b.x > p_cizimIler / 100.0) { o = s; return; }
  float tot = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; float sm = 0.0; for (int c = 0; c < 16; c++) { if (float(c) >= C) break; sm += max(dat(float(r), float(c)), 0.0); } tot = max(tot, sm); }
  float acc = 0.0; vec4 col = vec4(0.04, 0.06, 0.12, 0.85);
  for (int c = 0; c < 16; c++) { if (float(c) >= C) break; float v = mix(max(dat(r0, float(c)), 0.0), max(dat(min(r0 + 1.0, R - 1.0), float(c)), 0.0), f) / max(tot, 1e-6) * 0.9; if (b.y >= acc && b.y < acc + v) col = vec4(serCol(float(c), c_seriler), 1.0); acc += v; }
  o = col; }
