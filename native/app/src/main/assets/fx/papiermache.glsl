// papiermache
uniform float p_hamurYuks, p_lifBoyu, p_kenarYumu, p_yuzeyPuru;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float h = fbm01(q / max(p_lifBoyu * 4.0, 2.0), 4.0) * p_yuzeyPuru / 100.0 + smoothstep(0.0, p_kenarYumu * 0.3 * u_s + u_s, innerDist(here(), 30.0 * u_s)) * p_hamurYuks / 10.0;
  vec3 n = normalize(vec3(-dFdx(h) * 6.0, -dFdy(h) * 6.0, 1.0)); float lit = 0.55 + 0.6 * max(dot(n, normalize(vec3(-0.5, -0.5, 0.8))), 0.0); vec3 c = unpre(s) * lit * (0.92 + 0.08 * vnoise(q * 2.0)); o = pre(clamp(c, 0.0, 1.0), s.a); }
