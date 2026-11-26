// levels
uniform float p_kanal, p_girisSiya, p_girisBeya, p_gama, p_cikisSiya, p_cikisBeya;
float lv(float x) { float a = p_girisSiya / 100.0, b = max(a + 0.001, p_girisBeya / 100.0); x = clamp((x - a) / (b - a), 0.0, 1.0); x = pow(x, 1.0 / max(p_gama, 0.01)); return mix(p_cikisSiya / 100.0, p_cikisBeya / 100.0, x); }
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float a = s.a;
  if (p_kanal < 0.5) c = vec3(lv(c.r), lv(c.g), lv(c.b)); else if (p_kanal < 1.5) c.r = lv(c.r); else if (p_kanal < 2.5) c.g = lv(c.g); else if (p_kanal < 3.5) c.b = lv(c.b); else a = lv(a);
  o = pre(c, a);
}
