// hexpath
uniform sampler2D s_engelMask; uniform vec2 p_baslangi, p_hedef; uniform float p_engelMaskOn, p_hucre, p_ilerleme;
// Altıgen ızgarada açgözlü + engel çevresinden dolanan yol (her pikselde aynı deterministik yol); engeller kaynak maske ya da koyu bölgeler
vec2 hexC(vec2 h, float S) { return vec2(S * 1.5 * h.x, S * 1.7320508 * (h.y + 0.5 * mod(h.x, 2.0))); }
vec2 toHex(vec2 p, float S) { float x = floor(p.x / (S * 1.5) + 0.5); float y = floor(p.y / (S * 1.7320508) - 0.5 * mod(x, 2.0) + 0.5); vec2 best = vec2(x, y); float bd = 1e9; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 h = vec2(x + float(i), y + float(j)); float d = length(p - hexC(h, S)); if (d < bd) { bd = d; best = h; } } return best; }
bool blocked(vec2 h, float S) { vec2 c = hexC(h, S); if (p_engelMaskOn > 0.5) return texture(s_engelMask, boxUV(fromUnit(c))).a > 0.5; vec4 col = texU(c); return col.a > 0.5 && luma(unpre(col)) < 0.25; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float S = max(p_hucre, 4.0) * 0.5; vec2 me = toHex(q, S); vec2 goal = toHex(p_hedef, S); vec2 cur = toHex(p_baslangi, S);
  float onPath = 0.0; float steps = 0.0; float total = 1.0; vec2 prev = cur + vec2(99.0); for (int k = 0; k < 96; k++) { if (cur == goal) break; vec2 best = cur; float bd = 1e9;
    for (int n = 0; n < 6; n++) { vec2 nb; bool odd = mod(cur.x, 2.0) > 0.5; if (n == 0) nb = cur + vec2(0.0, 1.0); else if (n == 1) nb = cur + vec2(0.0, -1.0); else if (n == 2) nb = cur + vec2(1.0, odd ? 0.0 : -1.0); else if (n == 3) nb = cur + vec2(1.0, odd ? 1.0 : 0.0); else if (n == 4) nb = cur + vec2(-1.0, odd ? 0.0 : -1.0); else nb = cur + vec2(-1.0, odd ? 1.0 : 0.0);
      if (blocked(nb, S) || nb == prev) continue; float d = length(hexC(nb, S) - hexC(goal, S)) + hash1(nb) * 0.01; if (d < bd) { bd = d; best = nb; } }
    prev = cur; cur = best; steps += 1.0; if (cur == me) onPath = steps; }
  total = max(steps, 1.0); float lit = onPath > 0.0 && onPath / total <= p_ilerleme / 100.0 ? 1.0 : 0.0; vec2 c = hexC(me, S); float hd = hexDist(rot2(0.0) * (q - c) / (S * 1.7320508)); float edge = smoothstep(0.42, 0.48, hd);
  vec4 res = s; if (blocked(me, S)) res = mix(res, vec4(0.15, 0.15, 0.18, 1.0), 0.6); res = mix(res, vec4(1.0, 0.75, 0.25, 1.0), lit * 0.75); res = overPre(vec4(1.0) * edge * 0.25, res);
  if (me == toHex(p_baslangi, S)) res = mix(res, vec4(0.3, 0.9, 0.4, 1.0), 0.8); if (me == goal) res = mix(res, vec4(0.95, 0.3, 0.3, 1.0), 0.8); o = res; }
