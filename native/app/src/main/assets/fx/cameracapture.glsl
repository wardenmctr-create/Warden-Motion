// cameracapture
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_kaynakKame; uniform float p_kaynakKameOn, p_derinlikTole, p_cikti;
// İkinci (kaynak) kamera, ışık konumundaki bakış: oradan görünen yüzey maskesi ya da kaynak kamera görüntüsünün aktarımı
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); vec3 Cd = normalize(vec3(p_isikKonu.x, -p_isikKonu.y, -p_isikKonu.z) + vec3(0.0, 0.0, 1e-3)); float facing = dot(n, Cd);
  float vis = facing > 0.0 ? softShadow(p + n * max(p_derinlikTole, 0.2), Cd, 16.0) : 0.0; if (p_cikti < 0.5) return vec4(mix(vec3(0.08), vec3(1.0), step(0.5, vis)), 1.0);
  vec2 uv = vec2(p.x, -p.y) / boxU() + 0.5; vec4 k = p_kaynakKameOn > 0.5 ? texture(s_kaynakKame, uv) : vec4(1.0, 0.8, 0.3, 1.0); return vec4(mix(c.rgb * 0.5, k.rgb, step(0.5, vis)), 1.0); }
void main() { o = render3d(vec3(0.0)); }
