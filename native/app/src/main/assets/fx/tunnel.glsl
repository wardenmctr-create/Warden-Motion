// tunnel
INCLUDE(_3d)
uniform float p_tunelYari, p_tunelUzun, p_ilerleme, p_hiz, p_kameraAcis, p_dokuTekr, p_segment, p_sis;
float sdf(vec3 p) { return 1e5; } vec4 surf(vec3 p, vec3 n) { return vec4(0.0); }
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float F = max(B.x, B.y) * 0.5 / tan(radians(clamp(p_gorusAcis, 10.0, 120.0)) * 0.5);
  vec3 rd = normalize(vec3(q.x, -q.y, -F)); rd = rotXYZ(p_yonelimXY + vec3(0.0, 0.0, p_kameraAcis) + p_surekliDonuX * u_t) * rd;
  float r = max(p_tunelYari, 1.0); float t = r / max(length(rd.xy), 1e-4); vec3 p = rd * t;
  float z = -p.z + p_ilerleme + u_t * p_hiz; float ang = atan(p.y, p.x);
  vec2 uv = vec2(fract(ang / TAU * max(1.0, floor(p_dokuTekr * 0.5))), fract(z / max(p_tunelUzun, 1.0) * p_dokuTekr));
  vec4 c = layerAt(uv); vec3 col = c.a > 0.0 ? c.rgb / c.a : vec3(0.2);
  float fog = p_sis > 0.5 ? exp(-t / (r * 6.0)) : exp(-t / (r * 30.0)); col *= fog;
  o = vec4(col, 1.0);
}
