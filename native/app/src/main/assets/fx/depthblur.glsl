// depthblur
uniform sampler2D s_derinlikHari; uniform float p_derinlikHariOn; uniform sampler2D u_depth;
uniform float p_odakUzak, p_netAlan, p_bulanikl, p_diyafram, p_haritayiTersCevi; uniform vec2 p_odakNoktSec;
void main() {
  vec2 b = clamp(boxUV(here()), 0.0, 1.0);
  float d = p_derinlikHariOn > 0.5 ? luma(unpre(texture(s_derinlikHari, b))) : luma(unpre(texture(u_depth, v_uv)));
  if (p_haritayiTersCevi > 0.5) d = 1.0 - d;
  float f = p_odakUzak / 100.0; float k = smoothstep(p_netAlan / 200.0, p_netAlan / 200.0 + 0.25, abs(d - f));
  float R = p_bulanikl * u_s * 0.5 * k; if (R < 0.5) { o = texture(u_tex, v_uv); return; }
  vec4 acc = vec4(0.0); float ws = 0.0;
  for (int j = -5; j <= 5; j++) for (int i = -5; i <= 5; i++) { vec2 g = vec2(float(i), float(j)) / 5.0; if (length(g) > 1.0) continue; vec4 c = texPx(here() + g * R); float w = 1.0 + max(luma(unpre(c)) - 0.8, 0.0) * 4.0; acc += c * w; ws += w; }
  o = acc / ws;
}
