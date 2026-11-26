// lenticular
uniform sampler2D s_goruntul; uniform float p_goruntulOn, p_bakisAcis, p_seritSikl;
void main() { vec4 s = texture(u_tex, v_uv); vec4 b = p_goruntulOn > 0.5 ? texture(s_goruntul, clamp(boxUV(here()), 0.0, 1.0)) : vec4(vec3(1.0) - s.rgb, s.a); float stripe = fract(toUnit(here()).x / max(p_seritSikl, 1.0));
  float k = smoothstep(-15.0, 15.0, p_bakisAcis + (stripe - 0.5) * 20.0); vec4 c = mix(s, b, k); c.rgb *= 0.9 + 0.1 * sin(stripe * TAU); o = c; }
