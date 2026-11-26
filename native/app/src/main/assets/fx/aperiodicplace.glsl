// aperiodicplace
uniform sampler2D s_sekiller; uniform float p_sekillerOn, p_adet, p_bosluk, p_boyutDegi, p_tohum;
// Seyrek ızgara (adete göre) + hücre içi rastgele konum; hücre başına tek şekil → çakışma yok; boyut değişkenliği ve dönme tohumlu
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float cell = sqrt(boxU().x * boxU().y / max(p_adet, 1.0)); vec2 id0 = floor(q / cell); vec4 res = s;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = id0 + vec2(i, j); vec2 h = hash2(id + p_tohum * 0.137); float sz = cell * 0.5 * (1.0 - p_boyutDegi / 100.0 * hash1(id + 9.1 + p_tohum)) - p_bosluk;
    if (sz <= 0.5) continue; vec2 c = (id + 0.5 + (h - 0.5) * (1.0 - 2.0 * sz / cell) ) * cell; vec2 d = rot2(h.x * 360.0) * (q - c) / sz;
    if (any(greaterThan(abs(d), vec2(1.0)))) continue; vec4 sh = p_sekillerOn > 0.5 ? texture(s_sekiller, d * 0.5 + 0.5) : vec4(hsv2rgb(vec3(hash1(id + 2.2), 0.55, 0.95)), 1.0) * (1.0 - smoothstep(0.92, 1.0, length(d)));
    res = overPre(sh, res); } o = res; }
