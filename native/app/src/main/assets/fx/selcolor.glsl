// selcolor
uniform float p_renkGrub, p_camgobeg, p_macenta, p_sari, p_siyah, p_yontem;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float w;
  if (p_renkGrub < 5.5) { float r = p_renkGrub < 0.5 ? 1.0 : p_renkGrub < 1.5 ? 2.0 : p_renkGrub < 2.5 ? 3.0 : p_renkGrub < 3.5 ? 4.0 : p_renkGrub < 4.5 ? 5.0 : 6.0; w = hueRange(c, r); }
  else { float l = luma(c); float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); w = (1.0 - smoothstep(0.1, 0.35, sat)) * (p_renkGrub < 6.5 ? smoothstep(0.7, 0.95, l) : p_renkGrub < 7.5 ? 1.0 - abs(l - 0.5) * 2.0 : 1.0 - smoothstep(0.05, 0.3, l)); }
  vec3 cmy = 1.0 - c; vec3 adj = vec3(p_camgobeg, p_macenta, p_sari) / 100.0; float k = p_siyah / 100.0;
  cmy += (p_yontem < 0.5 ? adj * cmy : adj) * w; cmy += k * w * (p_yontem < 0.5 ? (1.0 - cmy) * 0.5 : vec3(0.5));
  o = pre(clamp(1.0 - cmy, 0.0, 1.0), s.a);
}
