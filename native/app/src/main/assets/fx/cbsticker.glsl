// cbsticker
INCLUDE(_mat)
uniform sampler2D s_malzOzel; uniform float p_malzOzelOn;
uniform float p_icKont, p_disKont, p_golgeUzak, p_golge, p_kose, p_bosluklaDold, p_altlikBicim, p_alfaYorum, p_alfaEsik, p_malzDoku, p_malz, p_dokuGucuS; uniform vec2 p_disKayma; uniform vec3 c_icRenk, c_disRenk;
float sA(vec2 px) { float a = texPx(px).a; if (p_alfaYorum < 0.5) return step(0.5, a); if (p_alfaYorum < 1.5) return a; if (p_alfaYorum < 2.5) return smoothstep(0.08, 0.55, a); return step(p_alfaEsik / 100.0, a); }
float dil(vec2 px, float r) { float m = sA(px); if (r < 0.5) return m; for (int k = 1; k <= 3; k++) { float rr = r * float(k) / 3.0; for (int i = 0; i < 16; i++) { float a = float(i) * TAU / 16.0 + float(k) * 0.4; m = max(m, sA(px + vec2(cos(a), sin(a)) * rr)); } } return m; }
void main() {
  vec4 s = texture(u_tex, v_uv); float wi = p_icKont * u_s, wo = p_disKont * u_s; vec2 off = p_disKayma * u_s;
  float a1 = dil(here(), wi); float a2 = p_altlikBicim > 0.5 ? dil(here() - off, wi + wo) : 0.0;
  if (p_altlikBicim > 1.5) { vec2 q = toUnit(here()); vec2 n = vec2(pnoise(q / max(p_disKont * 3.0, 3.0)), pnoise(q / max(p_disKont * 3.0, 3.0) + 9.0)) * p_disKont * 0.4; a2 = dil(here() - off + n * u_s, wi + wo); }
  if (p_kose > 0.5) { a1 = step(0.5, a1); a2 = step(0.5, a2); }
  vec3 dc = c_disRenk;
  if (p_malzDoku > 0.5) { int id = p_malz < 0.5 ? 1 : p_malz < 1.5 ? 3 : p_malz < 2.5 ? 5 : 13; vec2 mp = toUnit(here());
    vec3 t = p_malz > 3.5 && p_malzOzelOn > 0.5 ? unpre(texture(s_malzOzel, fract(mp / 200.0))) : matSample(id, mp, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0).rgb / max(matBase(id), vec3(0.05));
    dc = mix(dc, dc * t * matLight(id, mp, 2.0, vec4(0.3, 0.6, 0.0, 0.0), 0.4, 0.0, 4.0, 135.0), p_dokuGucuS / 100.0); }
  float sh = dil(here() - off - vec2(0.0, p_golgeUzak * u_s), wi + wo) * p_golge / 100.0;
  vec4 c = vec4(0.0, 0.0, 0.0, 1.0) * sh; c = overPre(vec4(dc, 1.0) * a2, c); c = overPre(vec4(c_icRenk, 1.0) * a1, c);
  o = overPre(s, c);
}
