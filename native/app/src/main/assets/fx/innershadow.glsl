// innershadow
uniform vec3 c_renk; uniform float p_opaklik, p_aci, p_mesafe, p_yumusakl, p_daralma;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float a = radians(p_aci); vec2 off = vec2(cos(a), sin(a)) * p_mesafe * u_s; float R = max(p_yumusakl * u_s, 1.0);
  float d = innerDist(here() - off, R) / R; float sh = (1.0 - smoothstep(p_daralma / 100.0, 1.0, d)) * p_opaklik / 100.0;
  if (texPx(here() - off).a < 0.5) sh = p_opaklik / 100.0;
  o = pre(mix(unpre(s), c_renk, sh), s.a);
}
