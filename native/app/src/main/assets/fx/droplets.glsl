// droplets
uniform float p_damlaSayi, p_damlaBuyu, p_buyuklukRast, p_yuvarlak, p_yukselti, p_saydamli, p_isikKiri, p_kenarParl, p_damlaHare, p_akisHizi, p_akisYonu, p_damlaIzi, p_izUzun, p_damlalarBirl;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec2 off = vec2(0.0); float mask = 0.0, rim = 0.0, trail = 0.0; float N = clamp(p_damlaSayi, 0.0, 150.0);
  vec2 dir = vec2(cos(radians(p_akisYonu)), sin(radians(p_akisYonu)));
  for (int i = 0; i < 150; i++) { if (float(i) >= N) break; float fi = float(i); vec2 h = hash2(vec2(fi, 1.7)); float r = p_damlaBuyu * 0.5 * (1.0 + (hash1(vec2(fi, 5.0)) - 0.5) * p_buyuklukRast / 50.0);
    vec2 c = (h - 0.5) * B; if (p_damlaHare > 0.5 && r > p_damlaBuyu * 0.45) { float sp = p_akisHizi * (r / max(p_damlaBuyu, 1.0)); c += dir * mod(u_t * sp + h.y * B.y, B.y * 1.2); c = mod(c + B * 0.6, B * 1.2) - B * 0.6; }
    vec2 d = q - c; d.y *= mix(1.6, 1.0, p_yuvarlak / 100.0); float l = length(d) / max(r, 0.5);
    if (p_damlaIzi > 0.5 && p_damlaHare > 0.5) { float al = dot(q - c, -dir); float pp = abs(dot(q - c, vec2(-dir.y, dir.x))); trail = max(trail, step(0.0, al) * (1.0 - smoothstep(0.0, p_izUzun, al)) * (1.0 - smoothstep(r * 0.15, r * 0.3, pp)) * 0.5); }
    if (l < 1.0) { float hgt = sqrt(1.0 - l * l); mask = max(mask, smoothstep(1.0, 0.85, l)); off = -d / max(r, 0.5) * hgt * r * p_isikKiri / 100.0 * 1.5 * p_yukselti / 60.0; rim = max(rim, smoothstep(0.7, 1.0, l) * smoothstep(1.0, 0.95, l)); } }
  vec4 ref = texPx(here() + off * u_s * 2.0); ref.rgb = mix(ref.rgb, ref.rgb * vec3(0.92, 0.97, 1.05), 0.5);
  vec4 c = mix(s, ref, mask * p_saydamli / 100.0); vec2 hl = q; c = overPre(vec4(1.0) * (rim * p_kenarParl / 100.0 + trail * 0.25) * max(s.a, 0.3), c); o = c; }
