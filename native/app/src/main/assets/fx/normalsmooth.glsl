// normalsmooth
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_agirlik, p_sertKena, p_guc, p_disaYone;
// Normal düzeltme: kartın kenarı güce göre yuvarlanır (yumuşak gölgeleme); sert kenar açısı küçükse daha az yuvarlama
float sdf(vec3 p) { float th = 20.0; float r = th * 0.45 * p_guc / 100.0 * (1.0 - p_sertKena / 360.0); float d2 = (0.5 - cardA(p.xy)) * 6.0; vec2 w = vec2(d2 + r, abs(p.z) - th * 0.5 + r); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - r; }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); return vec4(c.rgb * (p_disaYone > 0.5 ? 1.0 : 0.92), 1.0); }
void main() { o = render3d(vec3(0.0)); }
