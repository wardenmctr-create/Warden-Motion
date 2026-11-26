// spirograph
uniform float p_icDisYari, p_kalemUzak, p_cizimIler, p_cizgiKali; uniform vec3 c_cizgiReng;
vec2 spi(float t) { float R = min(boxU().x, boxU().y) * 0.45; float r = R * clamp(p_icDisYari / 1000.0 * 0.9, 0.05, 0.95); float d = r * p_kalemUzak / 100.0 * 2.0; return vec2((R - r) * cos(t) + d * cos((R - r) / r * t), (R - r) * sin(t) - d * sin((R - r) / r * t)); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float best = 1e9; float T = 20.0 * TAU * p_cizimIler / 100.0; vec2 prev = spi(0.0);
  for (int i = 1; i <= 600; i++) { float t = T * float(i) / 600.0; vec2 p = spi(t); vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); best = min(best, length(q - prev - ab * u)); prev = p; }
  o = overPre(vec4(c_cizgiReng, 1.0) * (1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8 / u_s, best)), s); }
