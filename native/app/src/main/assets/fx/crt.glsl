// crt
uniform float p_ekranKavi, p_taramaCizg, p_rgbMask, p_parlama, p_koseKara, p_renkKaym, p_kenarKirp;
void main() {
  vec2 b = boxUV(here()) - 0.5; float k = p_ekranKavi / 100.0 * 0.5; vec2 cb = b * (1.0 + k * dot(b, b)); vec2 px = boxPx(cb + 0.5);
  if (p_kenarKirp > 0.5 && (abs(cb.x) > 0.5 || abs(cb.y) > 0.5)) { o = vec4(0.0); return; }
  float ca = p_renkKaym * u_s; vec4 g = texPx(px); vec3 c = vec3(texPx(px + vec2(ca, 0.0)).r, g.g, texPx(px - vec2(ca, 0.0)).b); float a = g.a; if (a <= 0.0) { o = vec4(0.0); return; } c /= max(a, 1e-3);
  float sl = 0.5 + 0.5 * sin((cb.y + 0.5) * u_box.w / max(u_s * 1.5, 1.5) * PI); c *= mix(1.0, sl, p_taramaCizg / 100.0);
  float m = mod(floor(here().x / max(u_s, 1.0)), 3.0); vec3 mask = m < 0.5 ? vec3(1.0, 0.7, 0.7) : m < 1.5 ? vec3(0.7, 1.0, 0.7) : vec3(0.7, 0.7, 1.0); c *= mix(vec3(1.0), mask, p_rgbMask / 100.0);
  c += c * c * p_parlama / 100.0; c *= 1.0 - smoothstep(0.3, 0.75, length(cb) * 1.2) * p_koseKara / 100.0;
  o = pre(clamp(c, 0.0, 1.0), a);
}
