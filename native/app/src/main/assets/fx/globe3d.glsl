// globe3d
INCLUDE(_3d)
uniform sampler2D t_world_a, t_world_b, s_ozelHari; uniform float p_ozelHariOn;
uniform float p_buyukluk, p_eksenEgik, p_enlem, p_boylam, p_basiklik, p_harita, p_ulkeSini, p_sinirKali, p_atmosfer, p_atmosferKali, p_bulutlar, p_bulutYogu, p_bulutHizi, p_geceIsik, p_okyanusYans;
uniform vec3 c_sinirReng, c_atmosferReng;
float R0() { return max(p_buyukluk * 0.5, 2.0); }
float sdf(vec3 p) { float f = 1.0 - p_basiklik / 100.0; return (length(p * vec3(1.0, 1.0 / f, 1.0)) - R0()) * f; }
vec3 earthDir(vec3 p) { vec3 d = normalize(p); d = rotXYZ(vec3(0.0, 0.0, p_eksenEgik)) * d; d = rotXYZ(vec3(-p_enlem, 0.0, 0.0)) * d; d = rotXYZ(vec3(0.0, p_boylam, 0.0)) * d; return d; }
vec2 llUV(vec3 d) { return vec2(atan(d.x, d.z) / TAU + 0.5, 0.5 - asin(clamp(d.y, -1.0, 1.0)) / PI); }
vec4 surf(vec3 p, vec3 n) {
  vec3 d = earthDir(p); vec2 uv = llUV(d); vec4 A = texture(t_world_a, uv); vec4 Bm = texture(t_world_b, uv);
  float land = A.a * (1.0 - Bm.b); vec3 pol = A.a > 0.0 ? A.rgb / A.a : vec3(0.0); float lat = abs(d.y);
  vec3 ocean = mix(vec3(0.06, 0.24, 0.52), vec3(0.03, 0.12, 0.32), smoothstep(0.0, 0.8, lat)); vec3 col;
  float det = fbm01(uv * vec2(80.0, 40.0), 4.0);
  vec3 phys = mix(mix(vec3(0.20, 0.45, 0.18), vec3(0.62, 0.52, 0.32), smoothstep(0.15, 0.4, lat) * smoothstep(0.62, 0.42, lat) + det * 0.25), vec3(0.95), smoothstep(0.72, 0.85, lat));
  if (p_harita < 0.5) col = mix(ocean * 1.1, pol, land);
  else if (p_harita < 1.5) col = mix(ocean, phys, land);
  else if (p_harita < 2.5) col = mix(ocean * 0.8, phys * (0.75 + det * 0.4), land);
  else if (p_harita < 3.5) col = mix(vec3(0.01, 0.02, 0.05), vec3(0.04, 0.05, 0.07), land) + vec3(1.0, 0.75, 0.4) * Bm.g * 1.4;
  else col = p_ozelHariOn > 0.5 ? unpre(texture(s_ozelHari, uv)) : mix(ocean, phys, land);
  if (p_ulkeSini > 0.5) { float w = max(p_sinirKali, 0.0) / 2048.0; float b = Bm.r; for (int i = 0; i < 4; i++) { vec2 o = vec2(cos(float(i) * 1.57), sin(float(i) * 1.57)) * w; b = max(b, texture(t_world_b, uv + o).r); } col = mix(col, c_sinirReng, clamp(b * 1.4, 0.0, 1.0) * step(0.001, p_sinirKali + 1e-3)); }
  float ocn = 1.0 - land; vec3 Ld = normalize(vec3(-p_isikKonu.x, p_isikKonu.y, -p_isikKonu.z) * -1.0 + vec3(0.0, 0.0, 1e-3));
  col += vec3(pow(max(dot(reflect(-normalize(vec3(0.3, 0.5, 1.0)), n), vec3(0.0, 0.0, 1.0)), 0.0), 24.0)) * ocn * p_okyanusYans / 100.0;
  if (p_bulutlar > 0.5) { vec2 cu = uv + vec2(u_t * p_bulutHizi / 360.0, 0.0); float cl = smoothstep(0.55 - p_bulutYogu / 250.0, 0.85, fbm01(cu * vec2(24.0, 12.0), 5.0) + 0.1); col = mix(col, vec3(1.0), cl * 0.85); }
  if (p_geceIsik > 0.5 && p_harita < 2.5) { float dark = smoothstep(0.1, -0.3, dot(n, normalize(vec3(-0.6, 0.4, 0.7)))); col += vec3(1.0, 0.75, 0.4) * Bm.g * dark * 1.5; }
  return vec4(col, 1.0);
}
void main() {
  vec4 c = render3d(vec3(0.0));
  if (p_atmosfer > 0.5) { vec2 q = toUnit(here()) - p_konumXY.xy; float r = length(q) / (R0() * objScale().x); float th = p_atmosferKali / 100.0;
    float halo = smoothstep(1.0 + th * 2.5, 1.0, r) * step(0.98, r) * 0.9 + smoothstep(1.0 - th * 2.0, 1.0, r) * step(r, 1.0) * 0.5; c = overPre(vec4(c_atmosferReng, 1.0) * halo * step(0.0001, th), c); }
  o = c;
}
