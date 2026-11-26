// book3d
INCLUDE(_3d)
uniform sampler2D s_onKapaGors, s_arkaKapaGors, s_kitapSirtGors, s_sayfaGors; uniform float p_onKapaGorsOn, p_arkaKapaGorsOn, p_kitapSirtGorsOn, p_sayfaGorsOn;
uniform vec2 p_kitapBoyu; uniform float p_kalinlik, p_sayfaSayi, p_kapakKali, p_acilmaAcis, p_acikSayf, p_sayfaCevi, p_sayfaKivr, p_sayfaSert, p_sayfaCizg, p_sayfaGolg; uniform vec3 c_sayfaReng;
vec2 BS() { return max(p_kitapBoyu, vec2(10.0)); }
float boxd(vec3 p, vec3 b) { vec3 q = abs(p) - b; return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0); }
// Arka yarı sabit: x∈[0,W], kapak z∈[-T,-T+k], sayfalar z∈[-T+k,0]. Ön yarı sırt (x=0) etrafında açılma açısı kadar döner ve aynalanır.
float A_() { return radians(clamp(p_acilmaAcis, 0.0, 180.0)); }
vec3 toHalf(vec3 p, float side) { float a = A_() * 0.5; if (side > 0.0) a -= A_(); vec3 q = p; q.xz = mat2(cos(a), -sin(a), sin(a), cos(a)) * q.xz; if (side > 0.0) q.z = -q.z; return q; }
float halfD(vec3 p, float side, out float isPage) { float T = max(p_kalinlik, 2.0) * 0.5; float k = max(p_kapakKali, 0.5); vec3 q = toHalf(p, side); float W = BS().x;
  float cover = boxd(q - vec3(W * 0.5, 0.0, -T + k * 0.5), vec3(W * 0.5, BS().y * 0.5, k * 0.5));
  float curl = p_sayfaKivr / 100.0 * T * 0.5 * sin(clamp(q.x / W, 0.0, 1.0) * PI) * step(1.0, p_acilmaAcis);
  float pages = boxd(q - vec3(W * 0.5 - 1.5, 0.0, (-T + k) * 0.5 + curl * 0.5), vec3(W * 0.5 - 2.5, BS().y * 0.5 - 3.0, max((T - k) * 0.5 + curl * 0.5, 0.3)));
  isPage = step(pages, cover); return min(cover, pages); }
float sdf(vec3 p) { float a, b; float T = max(p_kalinlik, 2.0) * 0.5; vec3 sp = p; sp.xz = mat2(cos(A_() * 0.5), -sin(A_() * 0.5), sin(A_() * 0.5), cos(A_() * 0.5)) * sp.xz;
  float spine = boxd(sp - vec3(-max(p_kapakKali, 0.5) * 0.5, 0.0, 0.0), vec3(max(p_kapakKali, 0.5) * 0.5, BS().y * 0.5, T)) ;
  return min(p_acilmaAcis < 1.0 ? spine : 1e5, min(halfD(p, 1.0, a), halfD(p, -1.0, b))); }
vec4 surf(vec3 p, vec3 n) { float pg1, pg2; float d1 = halfD(p, 1.0, pg1), d2 = halfD(p, -1.0, pg2); float side = d1 < d2 ? 1.0 : -1.0; float pg = d1 < d2 ? pg1 : pg2;
  if (min(d1, d2) > 1.0) return vec4(c_tabanRenk * 0.7, 1.0);
  vec3 q = toHalf(p, side); vec2 uv = vec2(q.x / BS().x, 0.5 - q.y / BS().y); if (side > 0.0) uv.x = uv.x; float T = max(p_kalinlik, 2.0) * 0.5;
  if (pg > 0.5) { vec3 c = c_sayfaReng; bool top = q.z > -1.5; vec2 puv = side > 0.0 ? vec2(1.0 - uv.x, uv.y) : uv; if (top && p_sayfaGorsOn > 0.5) c = unpre(texture(s_sayfaGors, clamp(vec2(puv.x * 0.5 + (side > 0.0 ? 0.0 : 0.5), puv.y), 0.0, 1.0)));
    if (!top) c *= 0.86 + 0.14 * step(0.5, fract(q.z * 1.5)); if (top && p_sayfaCizg > 0.5) c *= 1.0 - 0.25 * step(0.92, fract(uv.y * 24.0)) * step(0.08, uv.y);
    if (p_sayfaGolg > 0.5 && top) c *= mix(0.65, 1.0, smoothstep(0.0, 0.15, uv.x)); return vec4(c, 1.0); }
  bool outer = q.z < -T + max(p_kapakKali, 0.5) * 0.5;
  vec4 c = side > 0.0 ? (p_onKapaGorsOn > 0.5 ? texture(s_onKapaGors, clamp(uv, 0.0, 1.0)) : layerAt(uv)) : (p_arkaKapaGorsOn > 0.5 ? texture(s_arkaKapaGors, clamp(vec2(1.0 - uv.x, uv.y), 0.0, 1.0)) : vec4(c_tabanRenk * 0.8, 1.0));
  if (!outer) c = vec4(c_tabanRenk * 0.6, 1.0);
  if (uv.x < 0.03 && p_kitapSirtGorsOn > 0.5) c = texture(s_kitapSirtGors, clamp(vec2(0.5, uv.y), 0.0, 1.0));
  return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
