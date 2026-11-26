// batik
uniform float p_baglamaNokt, p_yayilim; uniform vec3 c_renkler;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); int N = int(clamp(p_baglamaNokt, 1.0, 24.0)); float best = 1e9; for (int i = 0; i < 24; i++) { if (i >= N) break; vec2 c = (hash2(vec2(float(i), 3.3)) - 0.5) * boxU(); best = min(best, length(q - c)); }
  float d = best / max(p_yayilim / 100.0 * length(boxU()) * 0.3, 1.0); float rings = 0.5 + 0.5 * sin(d * 18.0 + fbm(q * 0.02, 3.0) * 4.0); float crack = smoothstep(0.92, 1.0, abs(pnoise(q * 0.06)) * 3.0);
  vec3 c = mix(vec3(0.96, 0.92, 0.84), c_renkler, smoothstep(0.3, 0.7, rings) * (1.0 - smoothstep(1.2, 2.2, d) * 0.5)); c = mix(c, c_renkler * 0.5, crack * 0.6); o = pre(c * mix(vec3(1.0), unpre(s), 0.3), s.a); }
