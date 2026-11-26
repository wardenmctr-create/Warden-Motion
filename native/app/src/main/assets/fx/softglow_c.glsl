// softglow_c
uniform sampler2D u_aux; uniform sampler2D u_src; uniform vec3 c_renk; uniform float p_yogunluk, p_parlakliEsig, p_orijinalAyriKoru;
void main() {
  vec4 s = texture(u_src, v_uv); vec4 b = texture(u_aux, v_uv); vec3 bc = b.a > 0.0 ? b.rgb / b.a : vec3(0.0);
  float k = smoothstep(p_parlakliEsig / 100.0 - 0.1, 1.0, luma(bc)) * p_yogunluk / 100.0;
  vec3 c = unpre(s); vec3 r = mix(c, screenB(c, bc * c_renk), k);
  if (p_orijinalAyriKoru > 0.5) r = mix(r, c, 0.25);
  float a = max(s.a, b.a * k);
  o = pre(clamp(r, 0.0, 1.0), max(s.a, a * 0.6));
}
