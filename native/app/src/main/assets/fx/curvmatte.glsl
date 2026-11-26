// curvmatte
uniform float p_secim, p_olcumOlce, p_esik, p_matYumu;
float avgA2(vec2 p, float r) { float a = 0.0; for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 o2 = vec2(i, j) / 3.0; if (length(o2) > 1.0) continue; a += step(0.5, texPx(p + o2 * r).a); } return a / 29.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float r = max(p_olcumOlce * u_s, 1.5); float k = (avgA2(p, r) - 0.5) * 2.0; float th = p_esik / 100.0; float sw = max(p_matYumu / max(p_olcumOlce, 1.0), 0.02);
  float m = p_secim < 0.5 ? smoothstep(th, th + sw, k) : (p_secim < 1.5 ? smoothstep(th, th + sw, -k) : smoothstep(th, th + sw, abs(k)));
  float band = 1.0 - smoothstep(r * 0.6, r * 1.2, s.a > 0.5 ? innerDist(p, r * 1.2) : outerDist(p, r * 1.2)); m *= band; o = vec4(vec3(m), m); }
