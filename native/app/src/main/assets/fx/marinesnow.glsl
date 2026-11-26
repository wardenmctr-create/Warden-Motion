// marinesnow
uniform vec3 c_renk; uniform float p_zerre, p_derinlik, p_akis, p_odak;
// Üç derinlik katmanında askıdaki zerreler; odaktan uzak katmanlar bulanık ve renge doğru solgun
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec3 acc = vec3(0.0); float al = 0.0; float dens = clamp(p_zerre / 150.0, 0.05, 20.0);
  for (int L = 0; L < 3; L++) { float z = (float(L) + 0.5) / 3.0; float sc = mix(1.6, 0.6, z); float cell = 36.0 / sqrt(dens) * sc; vec2 drift = vec2(sin(u_t * 0.3 + float(L)) * 6.0, u_t * p_akis * mix(1.0, 0.4, z) * 0.3);
    vec2 g = (q + drift) / cell; vec2 id = floor(g); for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 c = id + vec2(i, j); vec2 h = hash2(c + float(L) * 13.7); if (hash1(c + 3.3 + float(L)) > min(dens * 0.4, 1.0)) continue;
      vec2 pos = (c + h) * cell + vec2(sin(u_t * 0.7 + h.x * 6.28) * cell * 0.1, 0.0) - drift; float r = mix(2.2, 0.9, z) * (0.6 + h.y * 0.8); float blur = abs(z - p_odak / 100.0) * 6.0 + 0.6;
      float a = (1.0 - smoothstep(r - blur * 0.5, r + blur, length(q - pos))) * mix(0.85, 0.35, z); acc += mix(vec3(1.0), c_renk, z) * a; al += a; } }
  al = clamp(al, 0.0, 1.0); o = vec4(s.rgb * (1.0 - al) + clamp(acc, 0.0, 1.0) * al, max(s.a, al)); }
