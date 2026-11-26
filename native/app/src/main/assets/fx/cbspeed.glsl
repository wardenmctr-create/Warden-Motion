// cbspeed
uniform float p_yon, p_cizgiSayi, p_uzunluk, p_kalinlik, p_opaklik, p_hareketiTakiEt, p_tohum; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec2 n = vec2(-d.y, d.x); vec2 B = boxU(); float acc = 0.0; int N = int(clamp(p_cizgiSayi, 1.0, 80.0));
  for (int i = 0; i < 80; i++) { if (i >= N) break; vec2 h = hash2(vec2(float(i), seedf(p_tohum) + floor(u_t * 12.0) * 0.0)); float off = (h.x - 0.5) * dot(B, abs(n)) * 0.9;
    float start = dot(B, abs(d)) * 0.5 + h.y * 20.0; float L = p_uzunluk * (0.5 + h.y); float flick = fract(u_t * 3.0 + h.x); vec2 rel = q; float along = -dot(rel, d) - start - flick * 15.0; float ac = dot(rel, n) - off;
    float m = (1.0 - smoothstep(p_kalinlik * 0.5, p_kalinlik * 0.5 + 0.8, abs(ac))) * step(0.0, along) * step(along, L) * (1.0 - along / max(L, 1.0)); acc = max(acc, m); }
  o = overPre(s, vec4(c_renk, 1.0) * acc * p_opaklik / 100.0); }
