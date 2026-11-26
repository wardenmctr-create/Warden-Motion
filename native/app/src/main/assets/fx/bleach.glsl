// bleach
uniform float p_agartmaGucu, p_doygunlu, p_kontrast, p_golgeSevi, p_gren;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = luma(c); vec3 bl = overlayB(c, vec3(l));
  c = mix(c, bl, p_agartmaGucu / 100.0); c = satAdj(c, 1.0 + p_doygunlu / 100.0); c = conAdj(c, 1.0 + p_kontrast / 100.0, 0.5);
  c += p_golgeSevi / 100.0 * 0.25 * (1.0 - smoothstep(0.0, 0.5, l));
  c += (hash1(floor(here()) + floor(u_t * 24.0)) - 0.5) * p_gren / 100.0 * 0.4;
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
