// edgecrystal
uniform sampler2D s_baslangiMask; uniform vec3 c_renk; uniform float p_baslangiMaskOn, p_buyume, p_fasetBoyu, p_yonlilik;
// Maske kenarından dışa büyüyen fasetli kristaller: Voronoi hücresi başına düz gölgelenmiş yüzey; hücrenin büyüme payı tohumlu
float M(vec2 px) { return p_baslangiMaskOn > 0.5 ? texture(s_baslangiMask, boxUV(px)).a : texPx(px).a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (M(p) > 0.5) { o = s; return; } float F = max(p_fasetBoyu * u_s, 2.0); float G = p_buyume / 100.0 * F * 6.0; if (G <= 0.0) { o = s; return; }
  float d = outerDist(p, G * 1.1); if (d <= 0.0 || d > G) { o = s; return; } vec2 g = alphaGrad(p, 2.0); vec2 n = length(g) > 1e-5 ? -normalize(g) : vec2(0.0, -1.0);
  vec2 qq = p / F; qq = mix(qq, vec2(dot(qq, vec2(n.y, -n.x)), dot(qq, n) * 0.5), p_yonlilik / 100.0); vec4 v = voronoi(qq); float hgt = 0.35 + 0.65 * hash1(v.zw); if (d > G * hgt) { o = s; return; }
  vec3 fn = normalize(vec3(hash2(v.zw + 3.0) - 0.5, 0.6)); float sh = clamp(dot(fn, normalize(vec3(-0.4, -0.6, 0.8))), 0.0, 1.0); float edge = smoothstep(0.0, 0.04, v.y - v.x);
  vec3 c = c_renk * (0.55 + 0.6 * sh) * mix(1.25, 1.0, edge); o = overPre(vec4(c, 0.88), s); }
