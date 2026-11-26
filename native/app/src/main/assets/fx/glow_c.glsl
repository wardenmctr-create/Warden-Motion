// glow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_karistir, p_yalnizParl;
void main() {
  vec4 s = texture(u_src, v_uv); float g = clamp(texture(u_aux, v_uv).a * p_yogunluk / 100.0 * 1.8, 0.0, 1.0); vec4 gc = vec4(c_renk, 1.0) * g;
  if (p_yalnizParl > 0.5) { o = gc * (1.0 - s.a); return; }
  if (p_karistir < 0.5) o = vec4(s.rgb + gc.rgb * (1.0 - s.rgb) * (1.0 - s.a * 0.7), max(s.a, g));
  else if (p_karistir < 1.5) o = vec4(min(s.rgb + gc.rgb * (1.0 - s.a * 0.6), vec3(1.0)), max(s.a, g));
  else o = overPre(s, gc);
}
