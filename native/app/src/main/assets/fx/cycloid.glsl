// cycloid
uniform float p_yaricap, p_noktaUzak, p_donusSayi;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float r = max(p_yaricap, 1.0); float d = p_noktaUzak; float T = p_donusSayi * TAU; float W = r * T; vec2 off = vec2(-W * 0.5, boxU().y * 0.25); float best = 1e9; vec2 prev = off + vec2(0.0, -(r - d));
  for (int i = 1; i <= 500; i++) { float t = T * float(i) / 500.0; vec2 p = off + vec2(r * t - d * sin(t), -(r - d * cos(t))); vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); best = min(best, length(q - prev - ab * u)); prev = p; }
  float ground = 1.0 - smoothstep(0.5, 1.5, abs(q.y - off.y)); o = overPre(vec4(1.0, 0.6, 0.2, 1.0) * max(1.0 - smoothstep(1.0, 2.0, best), ground * 0.4), s); }
