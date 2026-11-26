// stroke
uniform float p_kalinlik, p_konum, p_opaklik, p_birlesim, p_yalnizCizg; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); float w = p_kalinlik * u_s; float ring;
  if (p_konum < 0.5) ring = clamp(dilateA(here(), w) - s.a, 0.0, 1.0);
  else if (p_konum < 1.5) ring = clamp(s.a - erodeA(here(), w), 0.0, 1.0);
  else ring = clamp(dilateA(here(), w * 0.5) - erodeA(here(), w * 0.5), 0.0, 1.0);
  vec4 st = vec4(c_renk, 1.0) * ring * p_opaklik / 100.0;
  if (p_yalnizCizg > 0.5) { o = st; return; }
  o = p_konum < 0.5 ? overPre(s, st) : overPre(st, s * (1.0 - ring * p_opaklik / 100.0));
}
