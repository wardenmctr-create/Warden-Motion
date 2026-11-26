// choke
uniform float p_kenarDegi, p_yumusatm, p_yineleme, p_kanal, p_matiGost;
void main() {
  vec4 s = texture(u_tex, v_uv); float r = abs(p_kenarDegi) * u_s * clamp(p_yineleme, 1.0, 8.0) * 0.5 + 0.0;
  float a = p_kenarDegi < 0.0 ? erodeA(here(), r) : dilateA(here(), r);
  float sm = p_yumusatm * u_s; if (sm > 0.3) { float acc = 0.0; for (int i = 0; i < 8; i++) { float an = float(i) * TAU / 8.0; acc += p_kenarDegi < 0.0 ? erodeA(here() + vec2(cos(an), sin(an)) * sm, r) : dilateA(here() + vec2(cos(an), sin(an)) * sm, r); } a = (a + acc) / 9.0; }
  if (p_matiGost > 0.5) { o = vec4(vec3(a), 1.0); return; }
  vec3 c = s.a > 0.01 ? unpre(s) : unpre(texPx(here() + normalize(-alphaGrad(here(), 2.0) + 1e-5) * r));
  o = pre(c, a);
}
