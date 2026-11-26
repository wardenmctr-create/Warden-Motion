// elasticline
uniform float p_gerilim, p_sarkma, p_dvN; uniform float p_dv[8];
void main() { vec4 s = texture(u_tex, v_uv); vec2 A = p_dvN >= 4.0 ? vec2(p_dv[0], p_dv[1]) : vec2(-boxU().x * 0.4, 0.0), B = p_dvN >= 4.0 ? vec2(p_dv[2], p_dv[3]) : vec2(boxU().x * 0.4, 0.0); vec2 q = toUnit(here());
  float span = length(B - A); float sag = p_sarkma * (1.0 - p_gerilim / 100.0) * (1.0 + 0.1 * sin(u_t * 3.0) * (1.0 - p_gerilim / 100.0)); float best = 1e9; vec2 prev = A;
  for (int i = 1; i <= 32; i++) { float t = float(i) / 32.0; vec2 pp = mix(A, B, t) + vec2(0.0, 4.0 * t * (1.0 - t) * sag); vec2 ab = pp - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); best = min(best, length(q - prev - ab * u)); prev = pp; }
  float w = mix(3.0, 1.5, clamp(span / 600.0, 0.0, 1.0)); o = overPre(vec4(0.95, 0.85, 0.7, 1.0) * (1.0 - smoothstep(w, w + 1.0, best)), s); }
