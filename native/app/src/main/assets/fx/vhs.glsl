// vhs
uniform float p_renkKaym, p_yatayBozu, p_gren, p_taramaCizg, p_renkSolm, p_tohum, p_zamanEtik;
void main() {
  vec2 px = here(); float y = (px.y - u_box.y) / u_s; float t = u_t; float sd = seedf(p_tohum);
  float jit = (vnoise(vec2(y * 0.05, t * 3.0 + sd)) - 0.5) * p_yatayBozu * 2.0 + step(0.97, hash1(vec2(floor(y / 3.0), floor(t * 15.0) + sd))) * p_yatayBozu * 3.0;
  vec2 p = px + vec2(jit * u_s, 0.0); float ca = p_renkKaym * u_s;
  vec4 g = texPx(p); vec4 c = vec4(texPx(p + vec2(ca, 0.0)).r, g.g, texPx(p - vec2(ca, 0.0)).b, max(g.a, max(texPx(p + vec2(ca, 0.0)).a, texPx(p - vec2(ca, 0.0)).a)));
  if (c.a <= 0.0) { o = c; return; } vec3 col = c.rgb / c.a; col = mix(col, vec3(luma(col)), p_renkSolm / 100.0 * 0.6); col = mix(col, col * vec3(1.05, 0.95, 1.1), 0.5);
  col += (hash1(floor(px) + floor(t * 30.0)) - 0.5) * p_gren / 100.0 * 0.5; col *= 1.0 - p_taramaCizg / 100.0 * 0.35 * step(0.5, fract(px.y / max(u_s * 2.0, 2.0)));
  o = pre(clamp(col, 0.0, 1.0), c.a);
}
