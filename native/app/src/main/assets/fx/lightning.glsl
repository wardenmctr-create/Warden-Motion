// lightning
uniform vec2 p_baslangi, p_bitis; uniform float p_cizgiKali, p_dallanma, p_kivrim, p_hale, p_yenilenm, p_tohum; uniform vec3 c_renk;
float bolt(vec2 q, vec2 A, vec2 B, float sd, float amp) {
  vec2 ab = B - A; float L = max(length(ab), 1.0); vec2 d = ab / L, n = vec2(-d.y, d.x); float t = clamp(dot(q - A, d) / L, 0.0, 1.0);
  float off = (fbm(vec2(t * 6.0, sd), 4.0)) * amp * sin(t * PI); return abs(dot(q - A, n) - off) + max(0.0, abs(dot(q - A, d) / L - 0.5) - 0.5) * L;
}
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float sd = seedf(p_tohum) + floor(u_t * p_yenilenm) * 3.7;
  float d = bolt(q, p_baslangi, p_bitis, sd, p_kivrim * 2.0);
  // dallar
  for (int i = 0; i < 3; i++) { if (hash1(vec2(float(i), sd)) > p_dallanma / 100.0) continue; float t0 = 0.2 + 0.2 * float(i); vec2 P = mix(p_baslangi, p_bitis, t0);
    vec2 ab = p_bitis - p_baslangi; vec2 E = P + rot2((hash1(vec2(sd, float(i))) - 0.5) * 120.0) * ab * 0.35; d = min(d, bolt(q, P, E, sd + float(i) * 9.0, p_kivrim) * 1.4); }
  float w = p_cizgiKali * 0.5; float core = 1.0 - smoothstep(w * 0.4, w, d); float glow = exp(-d / max(p_hale * 0.5, 0.5)) * 0.8;
  float fl = 0.6 + 0.4 * step(0.3, hash1(vec2(floor(u_t * 20.0), sd)));
  vec3 c = (mix(c_renk, vec3(1.0), core) * core + c_renk * glow) * fl;
  o = vec4(min(s.rgb + c, vec3(1.0)), max(s.a, clamp(core + glow, 0.0, 1.0) * fl));
}
