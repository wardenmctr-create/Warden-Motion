// curl
uniform float p_sabitKena, p_kivrimIler, p_kivrimYari, p_aci, p_golge, p_arkaYuz; uniform vec3 c_arkaRenk;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU();
  vec2 dir = p_sabitKena < 0.5 ? vec2(1, 0) : p_sabitKena < 1.5 ? vec2(-1, 0) : p_sabitKena < 2.5 ? vec2(0, 1) : vec2(0, -1);
  dir = rot2(p_aci) * dir; float span = abs(dot(B, abs(dir)));
  vec2 P = -dir * span * 0.5 + dir * span * (1.0 - p_kivrimIler / 100.0);
  float R = max(p_kivrimYari, 1.0); float d = dot(q - P, dir);
  vec4 front = vec4(0.0), back = vec4(0.0);
  if (d < 0.0) { front = texU(q); vec4 s = texU(q + dir * (PI * R - 2.0 * d)); if (s.a > 0.01) back = pre(p_arkaYuz > 0.5 ? c_arkaRenk * 0.92 : unpre(s) * 0.8, s.a);
    front.rgb *= 1.0 - p_golge / 100.0 * 0.5 * (1.0 - smoothstep(0.0, R, -d)); }
  else if (d < R) { float d1 = R * asin(d / R), d2 = R * (PI - asin(d / R)); front = texU(q + dir * (d1 - d)); front.rgb *= mix(1.0, 0.7, d / R * p_golge / 100.0);
    vec4 s = texU(q + dir * (d2 - d)); if (s.a > 0.01) back = pre((p_arkaYuz > 0.5 ? c_arkaRenk : unpre(s)) * mix(0.65, 1.0, d / R), s.a); }
  o = back.a > 0.01 ? overPre(back, front * (1.0 - back.a)) : front;
}
