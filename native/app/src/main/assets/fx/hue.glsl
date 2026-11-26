// hue
uniform float p_tonAcis, p_doygunlu, p_renkAral;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float w = hueRange(c, p_renkAral);
  vec3 h = hueRotate(c, p_tonAcis); h = satAdj(h, 1.0 + p_doygunlu / 100.0);
  o = pre(clamp(mix(c, h, w), 0.0, 1.0), s.a);
}
