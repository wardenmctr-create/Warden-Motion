// lensflare
uniform vec2 p_isikKonu; uniform float p_parlakli, p_olcek, p_mercekTipi, p_hale, p_yansimal, p_yalnizParl; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float S = max(p_olcek / 100.0, 0.01) * min(boxU().x, boxU().y); vec2 L = p_isikKonu; vec2 r = (q - L) / S;
  float d = length(r); float k = p_parlakli / 100.0;
  vec3 c = c_renk * (exp(-d * 18.0) * 2.0 + exp(-d * 4.0) * 0.5 * p_hale / 100.0);
  if (p_mercekTipi > 0.5 && p_mercekTipi < 1.5) c += vec3(0.4, 0.6, 1.0) * exp(-abs(r.y) * 60.0) * exp(-abs(r.x) * 1.5) * 1.2;
  else c += c_renk * pow(max(0.0, cos(atan(r.y, r.x) * 6.0)), 30.0) * exp(-d * 6.0) * 0.6;
  if (p_mercekTipi > 1.5) c += vec3(0.9, 0.7, 1.0) * exp(-abs(d - 0.35) * 60.0) * 0.4;
  if (p_yansimal > 0.5) { vec2 axis = -L / S; for (int i = 1; i <= 5; i++) { float t = float(i) * 0.38; vec2 g = L / S + axis * t * 2.0; float gd = length(q / S - g); float rs = 0.03 + 0.03 * float(i % 3);
      vec3 col = hsv2rgb(vec3(fract(0.1 * float(i) + 0.55), 0.6, 1.0)); c += col * (1.0 - smoothstep(rs * 0.8, rs, gd)) * 0.18; } }
  c *= k;
  if (p_yalnizParl > 0.5) { o = vec4(c, clamp(max(c.r, max(c.g, c.b)), 0.0, 1.0)); return; }
  o = vec4(min(s.rgb + c * (1.0 - s.rgb * 0.3), vec3(1.0)), max(s.a, clamp(max(c.r, max(c.g, c.b)), 0.0, 1.0)));
}
