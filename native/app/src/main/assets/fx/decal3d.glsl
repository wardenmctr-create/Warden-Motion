// decal3d
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_cikartma; uniform float p_cikartmaOn, p_yontem, p_aciSini, p_opaklik, p_yuzeyIsigKull; uniform vec3 p_konum, p_donus; uniform vec2 p_boyut;
float sdf(vec3 p) { return cardD(p, 20.0); }
vec4 surf(vec3 p, vec3 n) { vec4 base = cardSurf(p, n); mat3 R = rotXYZ(p_donus); vec3 l = transpose(R) * (p - vec3(p_konum.x, -p_konum.y, -p_konum.z)); vec2 uv = l.xy / max(p_boyut, vec2(1.0)) + 0.5; uv.y = 1.0 - uv.y;
  float facing = dot(n, R * vec3(0.0, 0.0, 1.0)); if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0))) || facing < cos(radians(p_aciSini))) return base;
  vec4 d = p_cikartmaOn > 0.5 ? texture(s_cikartma, uv) : vec4(vec3(1.0, 0.8, 0.2) * step(length(uv - 0.5), 0.4), step(length(uv - 0.5), 0.4)); float e = smoothstep(0.0, max(p_kenarYumu, 0.01) * 0.05, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
  return vec4(mix(base.rgb, d.a > 0.0 ? d.rgb / d.a : base.rgb, d.a * e * p_opaklik / 100.0), 1.0); }
void main() { o = render3d(vec3(0.0)); }
