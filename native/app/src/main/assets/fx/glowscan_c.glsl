// glowscan_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_yalnizHale;
void main() { vec4 s = texture(u_src, v_uv); vec4 g = texture(u_aux, v_uv) * p_yogunluk / 100.0 * 2.0; g.rgb *= c_renk;
  if (p_yalnizHale > 0.5) { o = min(g, vec4(1.0)); return; } o = vec4(min(s.rgb + g.rgb * (1.0 - s.rgb * 0.5), vec3(1.0)), max(s.a, min(g.a, 1.0))); }
