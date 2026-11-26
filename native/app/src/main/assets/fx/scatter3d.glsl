// scatter3d
uniform float p_alan, p_kopyaSayi, p_minimumMesa, p_tohum, p_boyutRast, p_yuzeyNormHiza; uniform vec3 p_alanBoyu, p_donusRast;
void main() { vec2 q = toUnit(here()); int N = int(clamp(p_kopyaSayi, 1.0, 160.0)); vec4 res = vec4(0.0); float F = 900.0; float sd = seedf(p_tohum);
  for (int i = 160; i >= 0; i--) { if (i >= N) continue; float fi = float(i); vec3 h = vec3(hash2(vec2(fi, sd)), hash1(vec2(fi, sd + 4.0))) - 0.5; vec3 P;
    if (p_alan < 0.5) P = h * p_alanBoyu; else if (p_alan < 1.5) { vec3 d = normalize(h + 1e-3); P = d * p_alanBoyu * 0.5; } else if (p_alan < 2.5) { float g = ceil(pow(float(N), 1.0 / 3.0)); vec3 id = vec3(mod(fi, g), mod(floor(fi / g), g), floor(fi / (g * g))); P = (id / max(g - 1.0, 1.0) - 0.5) * p_alanBoyu; }
    else { float a = fi / float(N) * TAU; P = vec3(cos(a) * p_alanBoyu.x * 0.5, h.y * p_alanBoyu.y * 0.1, sin(a) * p_alanBoyu.z * 0.5); }
    float persp = F / max(F + P.z, 50.0); vec2 c = P.xy * persp; float sc = persp * 0.25 * (1.0 + h.z * p_boyutRast / 50.0); vec3 r = h * 2.0 * p_donusRast;
    vec2 l = rot2(-r.z) * (q - c) / max(sc, 0.01); l.x /= max(abs(cos(radians(r.y))), 0.15); l.y /= max(abs(cos(radians(r.x))), 0.15); res = overPre(texU(l), res); }
  o = res; }
