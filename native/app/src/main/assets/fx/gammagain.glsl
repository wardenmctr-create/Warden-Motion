// gammagain
uniform float p_kanal, p_gama, p_taban, p_kazanc, p_siyahiSini;
float gg(float x) { x = x * p_kazanc + p_taban / 100.0; if (p_siyahiSini > 0.5) x = max(x, 0.0); return pow(max(x, 0.0), 1.0 / max(p_gama, 0.01)); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  if (p_kanal < 0.5) c = vec3(gg(c.r), gg(c.g), gg(c.b)); else if (p_kanal < 1.5) c.r = gg(c.r); else if (p_kanal < 2.5) c.g = gg(c.g); else c.b = gg(c.b);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
