// split
uniform vec2 p_yirtikMerk; uniform float p_aci, p_ayrilma, p_kenarPuru, p_tohum, p_yirtikGolg;
float side(vec2 p, vec2 d, vec2 n) { float s = dot(p - p_yirtikMerk, d); float j = (vnoise(vec2(s / 6.0, seedf(p_tohum))) - 0.5) * 2.0 * p_kenarPuru + (vnoise(vec2(s / 1.5, seedf(p_tohum) + 3.0)) - 0.5) * p_kenarPuru * 0.6; return dot(p - p_yirtikMerk, n) - j; }
void main() {
  vec2 q = toUnit(here()); float a = radians(p_aci); vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x); float h = p_ayrilma * 0.5;
  vec2 s1 = q - n * h, s2 = q + n * h; vec4 c = vec4(0.0);
  float e1 = side(s1, d, n), e2 = side(s2, d, n);
  if (e1 > 0.0) c = texU(s1); else if (e2 < 0.0) c = texU(s2);
  if (p_yirtikGolg > 0.5) { float g = 1.0 - smoothstep(0.0, 4.0, min(abs(e1), abs(e2))); c.rgb *= 1.0 - 0.35 * g * step(0.01, c.a); }
  o = c;
}
