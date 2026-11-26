// dustinlight
uniform sampler2D s_isikMask; uniform float p_isikMaskOn, p_zerre, p_akis, p_parlakli, p_maskeGeci;
// Zerreler yalnız ışık hacminde görünür (maske ya da üstten inen koni)
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 b = boxUV(here()); float m;
  if (p_isikMaskOn > 0.5) { float r = p_maskeGeci * u_s; m = 0.0; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) m += texture(s_isikMask, boxUV(here() + vec2(i, j) * r * 0.5)).a; m /= 9.0; }
  else { float w = 0.12 + b.y * 0.25; m = 1.0 - smoothstep(w - 0.05 - p_maskeGeci * 0.002, w + 0.05, abs(b.x - 0.5 - (b.y - 0.5) * 0.15)); }
  float dens = clamp(p_zerre / 300.0, 0.0, 15.0); float cell = 10.0 / sqrt(max(dens, 0.05)); vec2 dr = vec2(u_t * p_akis * 0.3, sin(u_t * 0.2) * 4.0); vec2 id = floor((q + dr) / cell); float v = 0.0;
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(i, j); vec2 h = hash2(c); vec2 pos = (c + h) * cell - dr + vec2(sin(u_t + h.x * 9.0), cos(u_t * 0.8 + h.y * 9.0)) * cell * 0.2;
    v += (1.0 - smoothstep(0.4, 1.1 + h.y, length(q - pos))) * (0.5 + 0.5 * sin(u_t * 3.0 + h.x * 20.0)); }
  float beam = m * 0.12; vec3 add = vec3(1.0, 0.96, 0.85) * (clamp(v, 0.0, 1.0) * m * p_parlakli / 100.0 + beam); o = vec4(s.rgb + add * (1.0 - s.a * 0.2), max(s.a, clamp(luma(add), 0.0, 1.0))); }
