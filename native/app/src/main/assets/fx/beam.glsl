// beam
uniform vec2 p_baslangi, p_bitis; uniform float p_basKali, p_sonKali, p_yumusakl, p_uzunluk, p_yalnizIsin; uniform vec3 c_cekirdekReng, c_disRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = mix(p_baslangi, p_bitis, p_uzunluk / 100.0); vec2 ab = B - p_baslangi; float L2 = max(dot(ab, ab), 1.0);
  float t = clamp(dot(q - p_baslangi, ab) / L2, 0.0, 1.0); float d = length(q - (p_baslangi + ab * t)); float w = mix(p_basKali, p_sonKali, t) * 0.5;
  float core = 1.0 - smoothstep(w * 0.4, w, d); float glow = exp(-max(d - w * 0.5, 0.0) / max(p_yumusakl * 0.5, 0.5));
  vec3 c = c_cekirdekReng * core + c_disRenk * glow * (1.0 - core * 0.5); float a = clamp(core + glow, 0.0, 1.0);
  o = p_yalnizIsin > 0.5 ? vec4(min(c, vec3(1.0)), a) : vec4(min(s.rgb + c, vec3(1.0)), max(s.a, a));
}
