// geodesicline3d
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 p_baslangi, p_bitis; uniform float p_kalinlik, p_ilerleme;
// Kart yüzeyindeki en kısa yol: ön yüzde düz çizgi (uçlar yüzeye iz düşürülür), ilerlemeye kadar
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); vec2 A = p_baslangi.xy, B = p_bitis.xy; if (length(A - B) < 1.0) { A = vec2(-boxU().x * 0.35, boxU().y * 0.25); B = vec2(boxU().x * 0.35, -boxU().y * 0.25); }
  B = mix(A, B, p_ilerleme / 100.0); vec2 ab = B - A; float t = clamp(dot(p.xy - A, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(p.xy - A - ab * t);
  float line = (1.0 - smoothstep(p_kalinlik * 0.5, p_kalinlik * 0.5 + 1.0, d)) * step(0.6, n.z); return vec4(mix(c.rgb, vec3(1.0, 0.8, 0.2), line), 1.0); }
void main() { o = render3d(vec3(0.0)); }
