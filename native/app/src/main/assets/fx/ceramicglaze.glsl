// ceramicglaze
uniform float p_sirAkis, p_catlakYogu, p_parlakli;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 fl = vec2(0.0, fbm(q * 0.02, 3.0) * p_sirAkis * 0.3); vec3 c = unpre(texU(q - fl)); vec4 v = voronoi(q / max(30.0 - p_catlakYogu * 0.25, 4.0));
  float crack = (1.0 - smoothstep(0.0, 0.05, v.y - v.x)) * p_catlakYogu / 100.0; c = mix(c, c * 0.55, crack); float h = fbm01(q * 0.04, 3.0); vec3 n = normalize(vec3(dFdx(h) * -20.0, dFdy(h) * -20.0, 1.0));
  float sp = pow(max(dot(reflect(normalize(vec3(-0.5, -0.5, -1.0)), n), vec3(0.0, 0.0, 1.0)), 0.0), 30.0) * p_parlakli / 100.0; o = pre(clamp(c * 1.05 + sp, 0.0, 1.0), s.a); }
