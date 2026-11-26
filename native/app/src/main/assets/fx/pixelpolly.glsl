// pixelpolly
uniform float p_ilerleme, p_ucgenBoyu, p_dagilma, p_yon, p_donme, p_yercekim, p_tohum, p_sure, p_otomatik;
void main() {
  vec2 q = toUnit(here()); float pr = p_otomatik > 0.5 ? clamp(u_t / max(p_sure, 0.05), 0.0, 1.0) : p_ilerleme / 100.0; if (pr <= 0.0) { o = texture(u_tex, v_uv); return; }
  float cs = max(p_ucgenBoyu, 2.0); vec2 dir0 = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec4 res = vec4(0.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) for (int t = 0; t < 2; t++) {
    vec2 cid = floor(q / cs) + vec2(float(i), float(j)); vec2 h = hash2(cid * 2.0 + float(t) + seedf(p_tohum)); vec2 home = (cid + (t == 0 ? vec2(0.33) : vec2(0.67))) * cs;
    float delay = h.x * 0.5; float pp = clamp((pr - delay) / max(1.0 - delay, 0.05), 0.0, 1.0);
    vec2 pos = home + (dir0 + (h - 0.5)) * p_dagilma * pp + vec2(0.0, p_yercekim * pp * pp * 0.5); float ang = p_donme * pp * (h.y - 0.5) * 2.0;
    vec2 src = home + rot2(-ang) * (q - pos); vec2 f = src / cs - cid; bool tri = t == 0 ? (f.x + f.y < 1.0) : (f.x + f.y >= 1.0);
    if (any(lessThan(f, vec2(0.0))) || any(greaterThan(f, vec2(1.0))) || !tri) continue;
    vec4 c = texU(src) * (1.0 - pp * 0.3); res = overPre(res, c); if (res.a > 0.99) break; }
  o = res;
}
