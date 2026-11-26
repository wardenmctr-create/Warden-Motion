// arrowfield
uniform sampler2D s_alan; uniform vec3 c_renk; uniform float p_alanOn, p_aralik, p_okBoyu, p_hizaGoreBoyu;
// Izgara üzerinde oklar: gövde alan yönünde (orta noktada bükülür), uzunluk isteğe bağlı büyüklükle; uçta üçgen baş
vec2 F(vec2 px) { if (p_alanOn > 0.5) return texture(s_alan, boxUV(px)).rg * 2.0 - 1.0; vec2 g = lumGrad(px, 3.0); return vec2(-g.y, g.x) * 8.0 + vec2(0.15, 0.0); }
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float G = max(p_aralik * u_s, 4.0); vec2 c = (floor(p / G) + 0.5) * G; vec2 f0 = F(c); float m = length(f0); if (m < 1e-4) { o = s; return; }
  float L = p_okBoyu * u_s * (p_hizaGoreBoyu > 0.5 ? clamp(m, 0.25, 1.5) : 1.0); vec2 d0 = f0 / m; vec2 a = c - d0 * L * 0.5; vec2 mid = c; vec2 f1 = F(c + d0 * L * 0.25); vec2 d1 = length(f1) > 1e-4 ? normalize(f1) : d0; vec2 e = mid + d1 * L * 0.5;
  float w = max(u_s * 0.8, 0.8); float sh = min(seg(p, a, mid), seg(p, mid, e - d1 * w * 2.0)); vec2 lp = p - e; vec2 tn = vec2(-d1.y, d1.x); float hx = dot(lp, -d1), hy = abs(dot(lp, tn));
  float head = step(0.0, hx) * step(hx, w * 5.0) * step(hy, (w * 5.0 - hx) * 0.55); float v = max(1.0 - smoothstep(w * 0.5, w * 0.5 + 0.8, sh), head); o = overPre(vec4(c_renk, 1.0) * v, s); }
