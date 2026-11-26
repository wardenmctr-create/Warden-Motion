// celticknot
uniform vec3 c_renk; uniform float p_tekrar, p_ipGeni, p_kesisimBosl, p_dugum;
// Köşegen iki iplik ailesi; her kesişimde dama düzenine göre üst/alt; alttaki iplik, üstün kenarında boşluk alır. Bölge kare ya da daire, kenarda döngü
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()) - 0.5; float N = max(p_tekrar, 2.0); vec2 g = b * N; vec2 r = vec2(g.x + g.y, g.x - g.y) * 0.70710678;
  float cellPx = min(u_box.z, u_box.w) / N * 0.7071; float w = p_ipGeni * u_s / max(cellPx, 1.0) * 0.5; float gap = p_kesisimBosl * u_s / max(cellPx, 1.0);
  float du = abs(fract(r.x) - 0.5), dv = abs(fract(r.y) - 0.5); float onU = 1.0 - smoothstep(w - 0.03, w, du), onV = 1.0 - smoothstep(w - 0.03, w, dv);
  float over = mod(floor(r.x) + floor(r.y), 2.0); float a = 0.0; vec3 col = c_renk;
  if (onU > 0.0 && onV > 0.0) { // kesişim: üstteki iplik tam, alttaki boşluk
    float topD = over > 0.5 ? du : dv; a = 1.0 - smoothstep(w - 0.03, w, topD); col *= 1.0 - 0.35 * smoothstep(w * 0.4, w, topD); }
  else if (onU > 0.0) { a = onU * (over < 0.5 ? smoothstep(w + gap * 0.0, w + gap + 0.04, dv) : 1.0); col *= 1.0 - 0.35 * smoothstep(w * 0.4, w, du); }
  else if (onV > 0.0) { a = onV * (over > 0.5 ? smoothstep(w, w + gap + 0.04, du) : 1.0); col *= 1.0 - 0.35 * smoothstep(w * 0.4, w, dv); }
  float bound = p_dugum < 0.5 ? max(abs(b.x), abs(b.y)) : length(b) * 1.15; a *= 1.0 - smoothstep(0.43, 0.45, bound);
  float rim = (1.0 - smoothstep(w * 0.5 / N, w / N, abs(bound - 0.44))) * step(0.0, 1.0); a = max(a, rim * 0.0); o = overPre(vec4(col, 1.0) * a, s); }
