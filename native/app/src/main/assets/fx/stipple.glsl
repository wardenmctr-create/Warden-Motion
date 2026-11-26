// stipple
uniform float p_noktaBoyu, p_yogunluk, p_boyutCesi, p_renk, p_tohum, p_arkaPlanSayd; uniform vec3 c_noktaReng;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 B = u_box.zw; float area = B.x * B.y; float cell = max(sqrt(area / max(p_yogunluk, 10.0)), 1.5);
  vec2 px = here() - u_box.xy; vec2 id = floor(px / cell); float ink = 0.0; vec3 col = c_noktaReng;
  for (int i = -1; i <= 1; i++) for (int j = -1; j <= 1; j++) { vec2 cid = id + vec2(float(i), float(j)); vec2 r = hash2(cid + seedf(p_tohum)); vec2 cp = (cid + r) * cell;
    vec4 x = texPx(cp + u_box.xy); float l = x.a > 0.0 ? luma(x.rgb / x.a) : 1.0; if (hash1(cid + 3.3) > (1.0 - l) * 1.25 || x.a < 0.1) continue;
    float rad = p_noktaBoyu * u_s * 0.5 * mix(1.0, 0.4 + (1.0 - l), p_boyutCesi / 100.0);
    float d = length(px - cp); float m = 1.0 - smoothstep(rad - 0.6, rad + 0.6, d); if (m > ink) { ink = m; if (p_renk < 0.5) col = x.rgb / x.a; } }
  if (p_arkaPlanSayd > 0.5) { o = vec4(col, 1.0) * ink; return; }
  o = pre(mix(vec3(0.98, 0.97, 0.94), col, ink), s.a);
}
