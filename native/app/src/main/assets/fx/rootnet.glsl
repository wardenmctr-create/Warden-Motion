// rootnet
uniform float p_hedef, p_dalEgim, p_buyume;
float seg(vec2 p, vec2 a, vec2 b) { vec2 ab = b - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); int N = int(clamp(p_hedef, 1.0, 40.0)); float best = 1e9; float grow = p_buyume / 100.0;
  for (int i = 0; i < 40; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), 2.0)); vec2 a = vec2((h.x - 0.5) * B.x * 0.3, -B.y * 0.5); vec2 tgt = vec2((h.y - 0.5) * B.x, B.y * (0.0 + 0.45 * hash1(vec2(float(i), 5.0))));
    vec2 prev = a; for (int k = 1; k <= 8; k++) { float t = float(k) / 8.0; if (t > grow) break; vec2 p = mix(a, tgt, t) + vec2(sin(t * 6.0 + float(i)) * p_dalEgim * 0.4, 0.0) * (1.0 - t); best = min(best, seg(q, prev, p) / (1.5 - t)); prev = p; } }
  o = overPre(vec4(0.55, 0.38, 0.22, 1.0) * (1.0 - smoothstep(1.0, 2.0, best)), s); }
