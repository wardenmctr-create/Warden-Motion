// thresholdrgb
uniform float p_kirmiziEsik, p_yesilEsik, p_maviEsik, p_gecis, p_tersCevi;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 t = vec3(p_kirmiziEsik, p_yesilEsik, p_maviEsik) / 100.0; float w = max(p_gecis / 200.0, 0.002);
  vec3 r = smoothstep(t - w, t + w, c); if (p_tersCevi > 0.5) r = 1.0 - r;
  o = pre(r, s.a);
}
