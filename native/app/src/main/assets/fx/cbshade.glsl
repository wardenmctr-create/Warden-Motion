// cbshade
uniform vec2 p_isikMerk; uniform vec3 c_isikReng, c_golgeReng; uniform float p_isikGucu, p_golgeGucu, p_kenarKara, p_yumusakl, p_alfayaKirp;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()); vec2 B = boxU(); float R = min(B.x, B.y) * 0.5;
  vec2 r = q / R; float d = length(r); vec3 n = vec3(r, sqrt(max(0.0, 1.0 - min(dot(r, r), 1.0)))); vec2 lp = p_isikMerk / R; vec3 L = normalize(vec3(lp, 0.9));
  float dif = dot(n, L); float hl = pow(max(dif, 0.0), mix(12.0, 2.0, p_yumusakl / 100.0)); float sh = smoothstep(0.2, -0.6, dif);
  vec3 c = unpre(s); c = mix(c, c_golgeReng, sh * p_golgeGucu / 100.0); c = mix(c, c_isikReng, hl * p_isikGucu / 100.0); c *= 1.0 - smoothstep(0.7, 1.0, d) * p_kenarKara / 100.0;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
