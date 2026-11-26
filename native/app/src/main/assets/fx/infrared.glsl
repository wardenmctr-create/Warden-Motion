// infrared
uniform float p_kirmiziKatk, p_yesilKatk, p_maviKatk, p_gokyuzuKara, p_tekRenk; uniform vec3 c_renkTonu;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float v = dot(c, vec3(p_kirmiziKatk, p_yesilKatk, p_maviKatk) / 100.0);
  float sky = smoothstep(0.1, 0.4, c.b - max(c.r, c.g)); v *= 1.0 - sky * p_gokyuzuKara / 100.0;
  v = clamp(v, 0.0, 1.0);
  vec3 r = p_tekRenk > 0.5 ? vec3(v) * c_renkTonu : vec3(v, c.g * 0.8 + v * 0.2, c.r * 0.6 + 0.1);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
