// upscale
uniform float p_olcek, p_ayrinti, p_gurultuAzal, p_kenarKesk, p_yontem, p_oraniKoru;
void main() {
  // katman ölçeğinde merkezden büyütür; kenar uyarlamalı keskinleştirme ile
  vec2 q = toUnit(here()) / max(p_olcek / 100.0, 0.01); vec2 p = fromUnit(q);
  vec4 c;
  if (p_yontem > 1.5) { vec2 g = floor((p - u_box.xy) / u_s) + 0.5; c = texPx(u_box.xy + g * u_s); }
  else { c = texPx(p); vec4 b = (texPx(p + vec2(1.0, 0.0)) + texPx(p - vec2(1.0, 0.0)) + texPx(p + vec2(0.0, 1.0)) + texPx(p - vec2(0.0, 1.0))) * 0.25;
    float k = (p_yontem < 0.5 ? (p_ayrinti / 100.0 + p_kenarKesk / 100.0) : p_ayrinti / 100.0 * 0.6) * (p_olcek / 100.0) * 0.6; c = c + (c - b) * k; c = mix(c, b, p_gurultuAzal / 100.0 * 0.4); }
  c.rgb = clamp(c.rgb, 0.0, max(c.a, 0.0)); o = c;
}
