// chanmix
uniform float p_cikisKana, p_kirmiziKatk, p_yesilKatk, p_maviKatk, p_sabit, p_tekRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float v = dot(c, vec3(p_kirmiziKatk, p_yesilKatk, p_maviKatk) / 100.0) + p_sabit / 100.0;
  vec3 r = c; if (p_tekRenk > 0.5) r = vec3(v); else if (p_cikisKana < 0.5) r.r = v; else if (p_cikisKana < 1.5) r.g = v; else r.b = v;
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
