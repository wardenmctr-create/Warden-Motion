// applique
INCLUDE(_mat)
uniform float p_renkBolg, p_kenarDiki, p_parcaOrtu, p_kumasMalz, p_dokuGucu;
void main() { vec4 s = texture(u_tex, v_uv); float k = max(pow(p_renkBolg, 1.0 / 3.0), 1.5); vec3 c = floor(unpre(s) * k + 0.5) / k; vec3 c2 = floor(unpre(texPx(here() + vec2(1.5 * u_s, 0.0))) * k + 0.5) / k; vec3 c3 = floor(unpre(texPx(here() + vec2(0.0, 1.5 * u_s))) * k + 0.5) / k;
  float edge = step(0.01, length(c - c2) + length(c - c3)); int m = p_kumasMalz < 0.5 ? 10 : 11; vec2 q = toUnit(here()); vec3 fab = matSample(m, q, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(luma(matBase(m)), 0.1);
  if (p_kumasMalz > 2.5 && p_kumasMalz < 3.5) fab *= vec3(0.8, 0.85, 1.05) * (0.9 + 0.2 * step(0.5, fract((q.x + q.y) * 0.5)));
  vec3 r = mix(c, c * fab, p_dokuGucu / 100.0); float stitch = edge > 0.0 ? 0.0 : step(0.5, fract(q.x / 3.0 + q.y / 3.0)) * (1.0 - smoothstep(p_kenarDiki * u_s * 0.5, p_kenarDiki * u_s, innerDist(here(), (p_kenarDiki + 2.0) * u_s))) * step(0.01, p_kenarDiki);
  r = mix(r, r * 0.55, edge * 0.8); r = mix(r, vec3(0.95), stitch * 0.7); o = pre(clamp(r, 0.0, 1.0), max(s.a, dilateA(here(), p_parcaOrtu * u_s) * 0.0 + s.a)); }
