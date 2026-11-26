// scanlines
uniform float p_cizgiAral, p_kalinlik, p_aci, p_opaklik, p_kayma, p_hiz; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } vec2 p = rot2(-p_aci) * toUnit(here()); float sp = max(p_cizgiAral, 0.5);
  float y = mod(p.y + p_kayma + u_t * p_hiz, sp); float l = 1.0 - smoothstep(p_kalinlik - 0.6 / u_s, p_kalinlik + 0.6 / u_s, y);
  o = pre(mix(unpre(s), c_renk, l * p_opaklik / 100.0), s.a); }
