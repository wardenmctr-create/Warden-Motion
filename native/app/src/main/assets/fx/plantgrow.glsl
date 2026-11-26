// plantgrow
uniform vec2 p_kok; uniform float p_bitkiBici, p_yineleme, p_dalAcis, p_dalUzun, p_kisalma, p_ilerleme, p_tohum, p_govdeKali, p_yaprakla; uniform vec3 c_dalReng, c_yaprakReng;
float segD(vec2 p, vec2 a, vec2 b, out float t) { vec2 ab = b - a; t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); return length(p - a - ab * t); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 root = p_kok; int D = int(clamp(p_yineleme, 1.0, 7.0)); float grow = p_ilerleme / 100.0 * float(D + 1); float sd = seedf(p_tohum);
  float wood = 0.0, leaf = 0.0; int total = (1 << (D + 1)) - 1; float k = p_kisalma / 100.0;
  for (int i = 0; i < 255; i++) { if (i >= total) break; int lvl = int(floor(log2(float(i + 1)))); int idx = i + 1 - (1 << lvl);
    // yolu kökten yürü: her seviye sol/sağ dal
    vec2 a = root; float ang = -90.0; float L = p_dalUzun; for (int j = 0; j < 8; j++) { if (j >= lvl) break; a += vec2(cos(radians(ang)), sin(radians(ang))) * L; int bit = (idx >> (lvl - 1 - j)) & 1;
      float jit = (hash1(vec2(float(i), float(j)) + sd) - 0.5) * 20.0; ang += (bit == 1 ? p_dalAcis : -p_dalAcis) * (p_bitkiBici > 0.5 && p_bitkiBici < 1.5 ? 0.6 : 1.0) + jit + (p_bitkiBici > 1.5 ? 25.0 : 0.0); L *= k; }
    float gl = clamp(grow - float(lvl), 0.0, 1.0); if (gl <= 0.0) continue; vec2 b = a + vec2(cos(radians(ang)), sin(radians(ang))) * L * gl; float t; float d = segD(q, a, b, t);
    float w = max(p_govdeKali * pow(0.65, float(lvl)), 0.6) * 0.5; wood = max(wood, 1.0 - smoothstep(w, w + 0.8, d));
    if (p_yaprakla > 0.5 && lvl >= D - 1) { vec2 lp = rot2(-ang) * (q - b); leaf = max(leaf, (1.0 - smoothstep(0.0, 0.8, length(lp / vec2(L * 0.35 + 3.0, L * 0.15 + 1.5)) - 1.0)) * gl); } }
  vec4 c = overPre(vec4(c_dalReng, 1.0) * wood, vec4(0.0)); c = overPre(vec4(c_yaprakReng, 1.0) * leaf, c); o = overPre(c, s); }
