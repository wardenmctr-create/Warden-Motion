// highshadow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform float p_acikTonl, p_golgeler, p_beyazlar, p_siyahlar, p_tonAral;
void main() {
  vec4 s = texture(u_src, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec4 bl = texture(u_aux, v_uv); float L = bl.a > 0.0 ? luma(bl.rgb / bl.a) : luma(c);
  float r = p_tonAral / 100.0 * 0.5 + 0.25;
  float wS = 1.0 - smoothstep(0.0, r * 2.0, L), wH = smoothstep(1.0 - r * 2.0, 1.0, L);
  float l = luma(c);
  float wB = smoothstep(0.75, 1.0, l), wK = 1.0 - smoothstep(0.0, 0.25, l);
  float d = p_golgeler / 100.0 * 0.45 * wS + p_acikTonl / 100.0 * 0.45 * wH + p_beyazlar / 100.0 * 0.3 * wB + p_siyahlar / 100.0 * 0.3 * wK;
  c = c + d * (d > 0.0 ? (1.0 - c) : c);
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
