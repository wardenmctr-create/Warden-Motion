// projectionpaint
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_projekto, s_goruntu; uniform float p_projektoOn, p_goruntuOn, p_kenarGeci, p_gizliYuzlUygu;
// Görüntü, projektör doğrultusundan (projektör katmanı yoksa ışık konumundan) yüzeye işlenir; gölgeleme yüzeyde kalır
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); vec3 D = normalize(vec3(p_isikKonu.x, -p_isikKonu.y, -p_isikKonu.z) + vec3(0.0, 0.0, 1e-3)); vec3 u = normalize(cross(D, vec3(0.0, 1.0, 0.001))); vec3 v = cross(u, D);
  vec2 uv = vec2(dot(p, u), -dot(p, v)) / max(boxU().x, boxU().y) + 0.5; vec4 img = p_goruntuOn > 0.5 ? texture(s_goruntu, uv) : vec4(step(0.5, fract(uv.x * 6.0)) * vec3(1.0, 0.4, 0.2) + (1.0 - step(0.5, fract(uv.x * 6.0))) * vec3(0.2, 0.5, 1.0), 1.0);
  float edge = smoothstep(0.0, max(p_kenarGeci / 100.0 * 0.5, 0.001), min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y))); float face = p_gizliYuzlUygu > 0.5 ? 1.0 : step(0.0, dot(n, D));
  return vec4(mix(c.rgb, img.rgb, img.a * edge * face), 1.0); }
void main() { o = render3d(vec3(0.0)); }
