// lightglow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_karistir, p_yalnizParl;
void main() {
  vec4 s = texture(u_src, v_uv); vec4 g = texture(u_aux, v_uv) * p_yogunluk / 100.0 * 2.2; g.rgb *= c_renk;
  if (p_yalnizParl > 0.5) { o = min(g, vec4(1.0)); return; }
  vec3 add = p_karistir < 0.5 ? g.rgb * (1.0 - s.rgb) : g.rgb;
  o = vec4(min(s.rgb + add, vec3(1.0)), max(s.a, min(1.0, g.a)));
}
