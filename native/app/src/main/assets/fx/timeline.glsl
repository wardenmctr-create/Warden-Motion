// timeline
INCLUDE(_chart)
uniform float p_yon, p_aralik, p_olayAral, p_cizgiKali, p_yaziBoyu, p_ilerleme, p_etiketCakiOnle; uniform vec3 c_cizgiReng;
void main() { vec2 b = boxUV(here()); vec2 q = p_yon < 0.5 ? b : b.yx; float R = dR(); float mn = 1e9, mx = -1e9; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; mn = min(mn, dat(float(r), 0.0)); mx = max(mx, dat(float(r), 0.0)); }
  float prog = p_ilerleme / 100.0; vec4 col = vec4(0.0); float L = boxU().x; float ln = (1.0 - smoothstep(p_cizgiKali / L * 0.5, p_cizgiKali / L * 0.5 + 0.002, abs(q.y - 0.5))) * step(q.x, 0.05 + 0.9 * prog); col = overPre(vec4(c_cizgiReng, 1.0) * ln, col);
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; float x = p_aralik < 0.5 ? 0.05 + (dat(float(r), 0.0) - mn) / max(mx - mn, 1e-6) * 0.9 : 0.05 + float(r) / max(R - 1.0, 1.0) * 0.9; if (x > 0.05 + 0.9 * prog + 1e-4) continue;
    float dot_ = 1.0 - smoothstep(0.008, 0.012, length((q - vec2(x, 0.5)) * vec2(L / boxU().y, 1.0) * vec2(boxU().y / L, 1.0))); col = overPre(vec4(1.0) * dot_, col);
    float up = (p_etiketCakiOnle > 0.5 && mod(float(r), 2.0) > 0.5) ? -1.0 : 1.0; vec2 lp = (q - vec2(x, 0.5 - up * 0.12)) * boxU() / max(p_yaziBoyu * 0.5, 4.0); col = overPre(vec4(1.0) * numAt(lp, dat(float(r), 0.0)), col); }
  o = col; }
