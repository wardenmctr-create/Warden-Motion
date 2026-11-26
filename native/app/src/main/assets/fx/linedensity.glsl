// linedensity
uniform float p_cizgiSayi, p_tonEtki, p_kivrim;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float L = luma(unpre(s)); float y = b.y * p_cizgiSayi + sin(b.x * 6.0 + b.y * 4.0) * p_kivrim / 100.0 * 2.0;
  float w = mix(0.5, (1.0 - L) * 0.9, p_tonEtki / 100.0); float line = 1.0 - smoothstep(w * 0.5 - 0.05, w * 0.5 + 0.05, abs(fract(y) - 0.5)); o = pre(vec3(1.0 - line), s.a); }
