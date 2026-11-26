// blackhole
uniform sampler2D s_bgsrc, s_bukuleceKatm; uniform float p_bgsrcOn, p_bukuleceKatmOn;
uniform vec2 p_merkez; uniform float p_merkezYari, p_bukulmeAlan, p_mercekEtki, p_girdapEtki, p_arkaPlanBuk, p_isikliDisk, p_diskGeni, p_diskEgim, p_diskDonuHizi, p_turbulan, p_parlama; uniform vec3 c_icDiskReng, c_disDiskReng;
vec4 bgAt(vec2 u) { vec2 b = boxUV(fromUnit(u)); if (p_bukuleceKatmOn > 0.5) return texture(s_bukuleceKatm, clamp(b, 0.0, 1.0)); if (p_arkaPlanBuk > 0.5 && p_bgsrcOn > 0.5) return texture(s_bgsrc, clamp(b, 0.0, 1.0)); return texU(u); }
void main() { vec2 q = toUnit(here()) - p_merkez; float r = length(q); float Rh = max(p_merkezYari * 0.5, 1.0); float A = max(p_bukulmeAlan, Rh * 1.5);
  float w = smoothstep(A, Rh, r); float bend = p_mercekEtki / 100.0 * Rh * Rh / max(r, 1.0) * 1.6 * w; float sw = p_girdapEtki / 100.0 * w * w * 3.0;
  vec2 dq = rot2(degrees(sw)) * (q - normalize(q + 1e-4) * bend); vec4 c = mix(texU(q + p_merkez), bgAt(dq + p_merkez), w > 0.0 ? 1.0 : 0.0);
  if (p_isikliDisk > 0.5) { float tilt = cos(radians(p_diskEgim)); vec2 dp = vec2(q.x, q.y / max(tilt, 0.08)); float dr = length(dp); float a = atan(dp.y, dp.x) - u_t * radians(p_diskDonuHizi);
    float ring = smoothstep(Rh * 1.3, Rh * 1.6, dr) * smoothstep(Rh * 1.6 + p_diskGeni, Rh * 1.4 + p_diskGeni * 0.5, dr);
    float tb = mix(1.0, fbm(vec2(a * 3.0, dr * 0.05), 3.0) * 1.6, p_turbulan / 100.0); float x = clamp((dr - Rh * 1.4) / max(p_diskGeni, 1.0), 0.0, 1.0);
    vec3 dc = mix(c_icDiskReng, c_disDiskReng, x) * (1.0 + 0.6 * cos(atan(dp.y, dp.x))) ; float behind = step(0.0, -q.y) * step(dr, Rh * 1.6 + p_diskGeni);
    float occl = (r < Rh * 1.05 && q.y < 0.0) ? 0.0 : 1.0; c = overPre(vec4(dc, 1.0) * clamp(ring * tb, 0.0, 1.0) * occl, c); }
  float hole = 1.0 - smoothstep(Rh * 0.98, Rh * 1.02, r); c = overPre(vec4(0.0, 0.0, 0.0, 1.0) * hole, c);
  c = overPre(vec4(c_icDiskReng, 1.0) * exp(-abs(r - Rh * 1.08) / max(Rh * 0.08, 0.5)) * p_parlama / 100.0 * 0.7, c); o = c; }
