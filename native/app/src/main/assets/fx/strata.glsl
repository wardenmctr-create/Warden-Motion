// strata
uniform float p_katman, p_kivrim; uniform vec3 c_mineralPale;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float y = b.y + sin(b.x * 5.0) * p_kivrim / 400.0 + fbm(b * 3.0, 4.0) * p_kivrim / 300.0; float id = floor(y * p_katman); float f = fract(y * p_katman);
  vec3 c = c_mineralPale * (0.6 + 0.6 * hash1(vec2(id, 4.0))) * (0.92 + 0.08 * vnoise(b * vec2(200.0, 20.0))); c *= 1.0 - smoothstep(0.92, 1.0, f) * 0.3; o = pre(clamp(c, 0.0, 1.0), s.a); }
