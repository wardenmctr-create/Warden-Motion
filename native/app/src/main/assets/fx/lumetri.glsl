// lumetri
uniform sampler2D s_yaraticiLut; uniform float p_yaraticiLutOn;
uniform float p_sicaklik, p_renkTonu, p_pozlama, p_kontrast, p_acikTonl, p_golgeler, p_beyazlar, p_siyahlar, p_doygunlu, p_canlilik, p_lutYogu, p_vinyet;
vec3 lut8(sampler2D t, vec3 c) { // 512x512 (8x8 karo, 64 düzey) LUT görseli
  float b = c.b * 63.0; float b0 = floor(b), b1 = min(63.0, b0 + 1.0);
  vec2 t0 = vec2(mod(b0, 8.0), floor(b0 / 8.0)), t1 = vec2(mod(b1, 8.0), floor(b1 / 8.0)); vec2 rg = c.rg * 63.0 / 64.0 + 0.5 / 64.0;
  vec3 a = texture(t, (t0 + rg) / 8.0).rgb, d = texture(t, (t1 + rg) / 8.0).rgb; return mix(a, d, b - b0); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s);
  c *= vec3(1.0 + p_sicaklik / 100.0 * 0.2, 1.0 - p_renkTonu / 100.0 * 0.15, 1.0 - p_sicaklik / 100.0 * 0.2);
  c = lin2srgb(srgb2lin(c) * exp2(p_pozlama)); c = conAdj(c, 1.0 + p_kontrast / 100.0, 0.5);
  float l = luma(c); c += p_golgeler / 100.0 * 0.3 * (1.0 - smoothstep(0.0, 0.5, l)) + p_acikTonl / 100.0 * 0.3 * smoothstep(0.5, 1.0, l);
  c += p_beyazlar / 100.0 * 0.2 * smoothstep(0.75, 1.0, l) + p_siyahlar / 100.0 * 0.2 * (1.0 - smoothstep(0.0, 0.25, l));
  c = satAdj(clamp(c, 0.0, 1.0), 1.0 + p_doygunlu / 100.0);
  float sat = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b)); c = satAdj(c, 1.0 + p_canlilik / 100.0 * (1.0 - sat));
  if (p_yaraticiLutOn > 0.5) c = mix(c, lut8(s_yaraticiLut, clamp(c, 0.0, 1.0)), p_lutYogu / 100.0);
  vec2 b = boxUV(here()) - 0.5; c *= 1.0 - p_vinyet / 100.0 * smoothstep(0.25, 0.75, length(b));
  o = pre(clamp(c, 0.0, 1.0), s.a);
}
