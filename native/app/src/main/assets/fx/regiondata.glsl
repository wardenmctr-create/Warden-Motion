// regiondata
INCLUDE(_chart)
uniform sampler2D t_world_id, t_world_b, s_bolgeGeom; uniform float p_bolgeGeomOn, p_siniflan, p_renkSiniSayi; uniform vec3 c_palet;
// her satır: "ülke kodu (ISO 3166 sayısal), değer" — ör. 792, 85 (Türkiye)
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = clamp(boxUV(here()), 0.0, 0.9999); ivec2 ts = textureSize(t_world_id, 0); vec3 idc = texelFetch(t_world_id, ivec2(b * vec2(ts)), 0).rgb; int code = int(idc.r * 255.0 + 0.5) * 256 + int(idc.g * 255.0 + 0.5);
  vec4 base = p_bolgeGeomOn > 0.5 ? texture(s_bolgeGeom, b) : vec4(mix(vec3(0.08, 0.14, 0.26), vec3(0.85), step(0.5, idc.b)), 1.0); if (idc.b < 0.5) { o = base; return; }
  float R = dR(); float mn = 1e9, mx = -1e9; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; mn = min(mn, dat(float(r), 1.0)); mx = max(mx, dat(float(r), 1.0)); }
  float val = -1e9; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; if (int(dat(float(r), 0.0) + 0.5) == code) val = dat(float(r), 1.0); }
  if (p_dvR < 0.5) val = mod(float(code) * 7.3, 100.0), mn = 0.0, mx = 100.0;
  vec4 c = base; if (val > -1e8) { float k = clamp((val - mn) / max(mx - mn, 1e-6), 0.0, 0.999); float N = max(floor(p_renkSiniSayi), 2.0);
    if (p_siniflan > 0.5 && p_siniflan < 1.5) { float below = 0.0, tot = 0.0; for (int r = 0; r < 64; r++) { if (float(r) >= R) break; tot += 1.0; below += step(dat(float(r), 1.0), val); } k = clamp(below / max(tot, 1.0) - 1e-3, 0.0, 0.999); }
    float cls = floor(k * N) / max(N - 1.0, 1.0); c = vec4(mix(vec3(0.97, 0.97, 0.95), c_palet * 0.55, cls), 1.0); }
  float border = texture(t_world_b, b).r; o = overPre(vec4(0.2, 0.2, 0.25, 1.0) * border * 0.8, c); }
