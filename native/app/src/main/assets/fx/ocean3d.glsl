// ocean3d
INCLUDE(_3d)
uniform float p_dalgaOlce, p_ruzgar, p_kopukEsig, p_zamanHizi;
float wave(vec2 x) { float t = u_t * p_zamanHizi / 100.0; float h = 0.0; float a = p_dalgaOlce * 0.12; vec2 d = vec2(1.0, 0.3);
  for (int i = 0; i < 5; i++) { float k = 0.02 * pow(1.8, float(i)); d = rot2(37.0) * d; h += sin(dot(x, d) * k + t * sqrt(9.8 * k) * 3.0) * a / pow(1.9, float(i)); } return h * (0.5 + p_ruzgar / 30.0); }
float sdf(vec3 p) { vec2 B = boxU() * 0.5; float plane = p.y - wave(p.xz) + B.y * 0.2; float box = max(abs(p.x) - B.x, abs(p.z) - B.x); return max(plane * 0.6, box); }
vec4 surf(vec3 p, vec3 n) { float h = wave(p.xz); float foam = smoothstep(p_kopukEsig / 100.0, 1.0, h / max(p_dalgaOlce * 0.12, 1.0) * 0.8 + 0.2); vec2 b = vec2(p.x / boxU().x + 0.5, p.z / boxU().x + 0.5); vec4 c = layerAt(fract(b));
  vec3 col = mix(vec3(0.02, 0.2, 0.35), c.a > 0.0 ? c.rgb : vec3(0.05, 0.3, 0.5), 0.25); return vec4(mix(col, vec3(0.95), foam), 1.0); }
void main() { o = render3d(vec3(0.0)); }
