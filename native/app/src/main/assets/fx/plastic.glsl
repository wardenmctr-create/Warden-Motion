// plastic
uniform float p_parlakYuze, p_kabartma, p_isikAcis, p_isikYuks, p_yuzeyPuru; uniform vec3 c_isikReng;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float st = max(1.0, p_kabartma * u_s * 0.5); vec2 g = lumGrad(here(), st) * st * 3.0 + alphaGrad(here(), st) * st * 2.0;
  g += (vec2(hash1(floor(here())), hash1(floor(here()) + 3.0)) - 0.5) * p_yuzeyPuru / 100.0 * 0.3;
  vec3 n = normalize(vec3(-g * p_kabartma * 0.4, 1.0)); float a = radians(p_isikAcis), e = radians(p_isikYuks);
  vec3 L = normalize(vec3(cos(a) * cos(e), sin(a) * cos(e), sin(e))); vec3 H = normalize(L + vec3(0, 0, 1));
  float sp = pow(max(dot(n, H), 0.0), mix(8.0, 60.0, p_parlakYuze / 100.0)) * p_parlakYuze / 100.0 * 1.5;
  vec3 c = unpre(s) * (0.75 + 0.35 * max(dot(n, L), 0.0)) + c_isikReng * sp;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
