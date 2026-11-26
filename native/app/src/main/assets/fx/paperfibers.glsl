// paperfibers
uniform vec3 c_lifReng; uniform float p_lifUzun, p_lifYogu, p_lifKali;
// Kesik kâğıt kenarından dışarı uzanan ince lifler: kenar boyunca tohumlu konumlar, normal yönünde hafif kıvrımlı
void main() { vec4 s = texture(u_tex, v_uv); if (s.a > 0.5) { o = s; return; } vec2 p = here(); float Lf = p_lifUzun * u_s; float d = outerDist(p, Lf * 1.2); if (d > Lf || d <= 0.0) { o = s; return; }
  vec2 g = alphaGrad(p - normalize(alphaGrad(p, 1.5) + 1e-5) * d, 1.5); vec2 n = length(g) > 1e-5 ? -normalize(g) : vec2(0.0, -1.0); vec2 t = vec2(-n.y, n.x);
  vec2 base = p - n * d; float along = dot(base, t); float sp = max(400.0 / max(p_lifYogu, 1.0), 0.6) * u_s; float id = floor(along / sp); float f = fract(along / sp);
  float h = hash1(vec2(id, 1.7)); float len = Lf * (0.3 + 0.7 * h); float curve = sin(d / max(Lf, 1.0) * 3.0 + h * 6.28) * sp * 0.3; float x = (f - 0.5) * sp - curve;
  float v = (1.0 - smoothstep(p_lifKali * u_s * 0.5, p_lifKali * u_s * 0.5 + 0.8, abs(x))) * step(d, len) * (1.0 - d / max(len, 1.0) * 0.6); o = vec4(c_lifReng, 1.0) * v; }
