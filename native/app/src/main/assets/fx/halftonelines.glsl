// halftonelines
uniform float p_cizgiAral, p_aci, p_enInceKali, p_enKaliKali, p_tersCevi; uniform vec3 c_murekkep, c_kagit;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float l = luma(unpre(s)); if (p_tersCevi > 0.5) l = 1.0 - l;
  float sp = max(p_cizgiAral * u_s, 1.5); vec2 p = rot2(-p_aci) * here(); float d = abs(fract(p.y / sp) - 0.5) * sp;
  float w = mix(p_enKaliKali, p_enInceKali, l) * u_s * 0.5; float ink = 1.0 - smoothstep(w - 0.6, w + 0.6, d);
  o = pre(mix(c_kagit, c_murekkep, ink), s.a);
}
