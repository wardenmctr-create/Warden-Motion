// lut
uniform sampler2D s_lutDosy; uniform float p_lutDosyOn; uniform float p_yogunluk, p_enterpol, p_girisProf, p_cikisiSini;
vec3 lut8(sampler2D t, vec3 c) { float b = c.b * 63.0; float b0 = floor(b), b1 = min(63.0, b0 + 1.0);
  vec2 t0 = vec2(mod(b0, 8.0), floor(b0 / 8.0)), t1 = vec2(mod(b1, 8.0), floor(b1 / 8.0)); vec2 rg = c.rg * 63.0 / 64.0 + 0.5 / 64.0;
  return mix(texture(t, (t0 + rg) / 8.0).rgb, texture(t, (t1 + rg) / 8.0).rgb, b - b0); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); if (p_girisProf > 2.5) c = pow(c, vec3(0.8)) * 1.1 - 0.05;
  vec3 r;
  if (p_lutDosyOn > 0.5) r = lut8(s_lutDosy, clamp(c, 0.0, 1.0));
  else { // dosya yoksa yerleşik sinema görünümü
    float l = luma(c); r = softLightB(c, mix(vec3(0.0, 0.45, 0.5), vec3(1.0, 0.62, 0.35), smoothstep(0.1, 0.9, l))); r = conAdj(r, 1.12, 0.5); }
  if (p_cikisiSini > 0.5) r = clamp(r, 0.0, 1.0);
  o = pre(clamp(mix(c, r, p_yogunluk / 100.0), 0.0, 1.0), s.a);
}
