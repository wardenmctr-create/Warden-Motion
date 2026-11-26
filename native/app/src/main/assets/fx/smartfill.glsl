// smartfill
uniform sampler2D s_onarimMask; uniform float p_onarimMaskOn;
uniform float p_maskeGeni, p_kenarYumu, p_yontem, p_aramaYari, p_yamaBoyu, p_gecisSayi, p_alfaBoslDold;
float holeAt(vec2 px) { float h = 0.0; if (p_onarimMaskOn > 0.5) h = texture(s_onarimMask, clamp(boxUV(px), 0.0, 1.0)).a; if (p_alfaBoslDold > 0.5) h = max(h, 1.0 - texPx(px).a) * step(0.001, 1.0); return h; }
void main() { vec4 s = texture(u_tex, v_uv); float g = p_maskeGeni * u_s; float h = holeAt(here()); if (g > 0.0) for (int i = 0; i < 8; i++) { float a = float(i) * 0.785; h = max(h, holeAt(here() + vec2(cos(a), sin(a)) * g)); }
  if (h <= 0.001) { o = s; return; }
  vec4 acc = vec4(0.0); float ws = 0.0; float maxR = max(p_aramaYari, 4.0) * u_s; int D = 8 + int(clamp(p_gecisSayi, 1.0, 8.0)) * 2;
  for (int i = 0; i < 24; i++) { if (i >= D) break; float a = float(i) * TAU / float(D); vec2 dir = vec2(cos(a), sin(a)); float t = 2.0;
    for (int k = 0; k < 24; k++) { vec2 p = here() + dir * t; if (holeAt(p) < 0.5) { vec4 c = texPx(p + (p_yontem > 0.5 ? dir * p_yamaBoyu * u_s * hash1(p) : vec2(0.0))); float w = 1.0 / (t * t + 1.0); acc += c * w; ws += w; break; } t += maxR / 24.0; } }
  vec4 f = ws > 0.0 ? acc / ws : s; float soft = p_kenarYumu > 0.0 ? smoothstep(0.0, 1.0, h) : step(0.5, h); o = mix(s, f, soft); }
