// huesat
uniform float p_renkAral, p_ton, p_doygunlu, p_aciklik, p_renklend, p_renklendTonu, p_renklendDoyg;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsl(c); vec3 r;
  if (p_renklend > 0.5) r = hsl2rgb(vec3(fract(p_renklendTonu / 360.0), p_renklendDoyg / 100.0, h.z));
  else { h.x = fract(h.x + p_ton / 360.0); h.y = clamp(h.y * (1.0 + p_doygunlu / 100.0), 0.0, 1.0); r = hsl2rgb(h); }
  r = p_aciklik >= 0.0 ? mix(r, vec3(1.0), p_aciklik / 100.0) : r * (1.0 + p_aciklik / 100.0);
  o = pre(clamp(mix(c, r, p_renklend > 0.5 ? 1.0 : hueRange(c, p_renkAral)), 0.0, 1.0), s.a);
}
