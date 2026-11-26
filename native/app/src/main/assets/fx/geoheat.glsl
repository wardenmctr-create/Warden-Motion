// geoheat
INCLUDE(_chart)
uniform sampler2D t_world_a; uniform float p_yaricap, p_agirligaGoreNorm; uniform vec3 c_renkPale;
void main() { vec2 b = boxUV(here()); vec4 land = texture(t_world_a, b); vec4 col = mix(vec4(0.05, 0.12, 0.25, 1.0), vec4(0.18, 0.22, 0.3, 1.0), land.a); float R = dR(); float h = 0.0; float M = 1e-6;
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; M = max(M, dC() >= 3.0 ? dat(float(r), 2.0) : 1.0); }
  for (int r = 0; r < 64; r++) { if (float(r) >= R) break; float lat = p_dvR > 0.5 ? dat(float(r), 0.0) : sin(float(r) * 1.7) * 50.0, lon = p_dvR > 0.5 ? dat(float(r), 1.0) : cos(float(r) * 2.3) * 150.0;
    vec2 p = vec2(lon / 360.0 + 0.5, 0.5 - lat / 180.0); float w = dC() >= 3.0 ? dat(float(r), 2.0) : 1.0; if (p_agirligaGoreNorm > 0.5) w /= M; float d = length((b - p) * boxU()); h += w * exp(-d * d / max(p_yaricap * p_yaricap * 0.25, 1.0)); }
  vec3 hc = mix(c_renkPale, vec3(1.0, 0.85, 0.2), smoothstep(0.4, 1.2, h)); o = overPre(vec4(hc, 1.0) * clamp(h, 0.0, 0.9), col); }
