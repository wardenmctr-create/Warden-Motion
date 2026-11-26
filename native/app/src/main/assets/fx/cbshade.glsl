// cbshade
uniform vec2 p_isikMerk, p_isik2Konum; uniform vec3 c_isikReng, c_golgeReng, c_isik2Renk;
uniform float p_isikGucu, p_golgeGucu, p_kenarKara, p_yumusakl, p_alfayaKirp, p_yuzeyParlak, p_noktaBuyu, p_noktaGuc, p_isik2, p_isik2Guc, p_bayrakKoru, p_konturIsik;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 q = toUnit(here()); vec2 B = boxU(); float R = min(B.x, B.y) * 0.5;
  vec2 r = q / R; float d = length(r); vec3 n = vec3(r, sqrt(max(0.0, 1.0 - min(dot(r, r), 1.0)))); vec3 L = normalize(vec3(p_isikMerk / R, 0.9));
  float dif = dot(n, L); float hl = pow(max(dif, 0.0), mix(12.0, 2.0, p_yumusakl / 100.0)); float sh = smoothstep(0.2, -0.6, dif);
  vec3 c = unpre(s); bool dark = luma(c) < 0.12; float k = (dark && p_konturIsik < 0.5) ? 0.0 : 1.0;
  float keep = p_bayrakKoru > 0.5 ? 0.75 : 1.0;
  c = mix(c, c_golgeReng, sh * p_golgeGucu / 100.0 * keep * k); c = mix(c, c_isikReng, hl * p_isikGucu / 100.0 * keep * k);
  float spot = pow(max(dot(reflect(-L, n), vec3(0, 0, 1)), 0.0), mix(200.0, 8.0, p_noktaBuyu / 100.0)); c += c_isikReng * spot * (p_noktaGuc / 100.0 + p_yuzeyParlak / 100.0 * 0.4) * k;
  if (p_isik2 > 0.5) { vec3 L2 = normalize(vec3(p_isik2Konum / R, 0.6)); c += c_isik2Renk * pow(max(dot(n, L2), 0.0), 4.0) * p_isik2Guc / 100.0 * k; }
  c *= 1.0 - smoothstep(0.7, 1.0, d) * p_kenarKara / 100.0 * k;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
