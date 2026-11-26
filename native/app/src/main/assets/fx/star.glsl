// star
uniform vec2 p_merkez; uniform float p_boyut, p_ucSayi, p_icYari, p_aci, p_hale, p_titreme; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 r = rot2(-p_aci) * (toUnit(here()) - p_merkez) / max(p_boyut * 0.5, 1.0);
  float n = max(3.0, floor(p_ucSayi)); float a = atan(r.y, r.x); float d = length(r);
  float spike = pow(abs(cos(a * n * 0.5)), mix(2.0, 40.0, 1.0 - p_icYari / 100.0)); float shape = 1.0 - smoothstep(0.0, 1.0, d / mix(0.08, 1.0, spike));
  float fl = 1.0 + 0.25 * sin(u_t * p_titreme * TAU) * step(0.01, p_titreme);
  float glow = exp(-d * max(p_boyut * 0.5, 1.0) / max(p_hale, 0.5)) * 0.7;
  float k = clamp((shape + glow) * fl, 0.0, 1.0);
  o = vec4(min(s.rgb + c_renk * k, vec3(1.0)), max(s.a, k));
}
