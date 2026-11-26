// interference
uniform vec2 p_birinciMerk, p_ikinciMerk; uniform float p_bicim, p_birinciDalgBoyu, p_ikinciDalgBoyu, p_fazFark, p_hiz, p_kontrast; uniform vec3 c_birinciRenk, c_ikinciRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float t = u_t * p_hiz * TAU; float w1, w2;
  float d1 = p_bicim > 0.5 && p_bicim < 1.5 ? q.x : length(q - p_birinciMerk); float d2 = p_bicim > 0.5 ? dot(q - p_ikinciMerk, normalize(vec2(1.0, 0.3))) : length(q - p_ikinciMerk);
  w1 = sin(d1 / max(p_birinciDalgBoyu, 1.0) * TAU - t); w2 = sin(d2 / max(p_ikinciDalgBoyu, 1.0) * TAU - t + radians(p_fazFark)); float v = (w1 + w2) * 0.25 + 0.5; v = clamp((v - 0.5) * (1.0 + p_kontrast / 25.0) + 0.5, 0.0, 1.0);
  o = pre(mix(c_birinciRenk, c_ikinciRenk, v), 1.0) * s.a; }
