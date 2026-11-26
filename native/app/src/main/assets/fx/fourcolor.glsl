// fourcolor
uniform vec3 c_solUstRenk, c_sagUstRenk, c_solAltRenk, c_sagAltRenk; uniform float p_gecisYumu, p_karistir;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 b = clamp(boxUV(here()), 0.0, 1.0); float k = mix(4.0, 1.0, p_gecisYumu / 100.0);
  vec2 f = vec2(pow(b.x, k) / (pow(b.x, k) + pow(1.0 - b.x, k)), pow(b.y, k) / (pow(b.y, k) + pow(1.0 - b.y, k)));
  vec3 g = mix(mix(c_solUstRenk, c_sagUstRenk, f.x), mix(c_solAltRenk, c_sagAltRenk, f.x), f.y);
  o = pre(blendMode(unpre(s), g, p_karistir), s.a);
}
