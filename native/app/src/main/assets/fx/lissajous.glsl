// lissajous
uniform vec2 p_frekansl; uniform float p_faz, p_cizgiKali;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 A = boxU() * 0.45; float best = 1e9; vec2 prev = vec2(sin(radians(p_faz)), 0.0) * A;
  for (int i = 1; i <= 400; i++) { float t = TAU * float(i) / 400.0; vec2 p = vec2(sin(p_frekansl.x * t + radians(p_faz) + u_t * 0.3), sin(p_frekansl.y * t)) * A; vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); best = min(best, length(q - prev - ab * u)); prev = p; }
  o = overPre(vec4(0.2, 0.6, 1.0, 1.0) * (1.0 - smoothstep(p_cizgiKali * 0.5, p_cizgiKali * 0.5 + 0.8 / u_s, best)), s); }
