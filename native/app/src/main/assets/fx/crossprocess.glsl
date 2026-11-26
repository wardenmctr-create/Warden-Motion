// crossprocess
uniform float p_yesilKaym, p_maviKaym, p_kontrast, p_doygunlu, p_gorunum;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  vec3 r = p_gorunum < 0.5 ? vec3(smoothstep(0.05, 0.95, c.r), pow(c.g, 0.85), c.b * 0.7 + 0.15) : p_gorunum < 1.5 ? vec3(pow(c.r, 1.2), smoothstep(0.0, 1.0, c.g), pow(c.b, 0.7) * 0.85 + 0.1) : c;
  r.g += p_yesilKaym / 100.0 * 0.15; r.b += p_maviKaym / 100.0 * 0.15;
  r = conAdj(r, 1.0 + p_kontrast / 100.0, 0.5); r = satAdj(r, 1.0 + p_doygunlu / 100.0);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
