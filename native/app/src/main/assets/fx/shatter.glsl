// shatter
uniform vec2 p_merkez; uniform float p_ilerleme, p_parcaSayi, p_parcaBici, p_dagilma, p_donus, p_yercekim, p_derinlik, p_tohum, p_otomatik, p_sure;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float pr = p_otomatik > 0.5 ? clamp(u_t / max(p_sure, 0.05), 0.0, 1.0) : p_ilerleme / 100.0; if (pr <= 0.0) { o = texture(u_tex, v_uv); return; }
  float cs = sqrt(B.x * B.y / max(p_parcaSayi, 2.0)); vec4 res = vec4(0.0);
  // Parçalar hücrelerde; her pikselde yakın hücrelerin parçası geri dönüştürülerek aranır
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) {
    vec2 cid = floor(q / cs) + vec2(float(i), float(j)); vec2 h = hash2(cid + seedf(p_tohum)); vec2 home = (cid + 0.5) * cs;
    vec2 dir = normalize(home - p_merkez + (h - 0.5) * cs); float dist = p_dagilma * pr * (0.5 + h.x) ; vec2 pos = home + dir * dist + vec2(0.0, p_yercekim * pr * pr * 0.6);
    float ang = p_donus * pr * (h.y - 0.5) * 2.0; float sc = 1.0 - p_derinlik / 100.0 * pr * h.y * 0.6;
    vec2 local = rot2(-ang) * (q - pos) / max(sc, 0.05); vec2 src = home + local;
    // kaynak nokta bu parçanın hücresinde mi (cam: voronoi benzeri sınır)
    vec2 sid = floor(src / cs); bool own = sid == cid;
    if (p_parcaBici < 0.5) { vec4 v = voronoi(src / cs + seedf(p_tohum)); own = distance(v.zw, cid + seedf(p_tohum) - fract(seedf(p_tohum))) < 0.5 || own; }
    if (!own) continue; vec4 c = texU(src); c.rgb *= 1.0 - 0.25 * pr * h.x; res = overPre(res, c * (1.0 - res.a) + res * 0.0); if (res.a > 0.99) break; }
  o = res;
}
