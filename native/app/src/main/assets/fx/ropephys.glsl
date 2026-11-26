// ropephys
uniform vec2 p_baslangi, p_bitis, p_ruzgar; uniform float p_uzunluk, p_kalinlik, p_sertlik, p_sonum, p_yercekim; uniform vec3 c_renk;
// İp: iki uç arası sarkık eğri (zincir eğrisi yaklaşımı); fazla uzunluk sarkmayı, rüzgâr ve sönümlü salınım yanal hareketi belirler
vec2 ropeAt(float t) { vec2 A = p_baslangi, B = p_bitis; float span = length(B - A); float slack = max(p_uzunluk - span, 0.0); float sag = sqrt(slack * max(span, 1.0) * 0.375) * (p_yercekim / 300.0) * (1.0 - p_sertlik / 200.0);
  float sw = sin(u_t * (1.0 + p_sertlik / 30.0)) * exp(-u_t * p_sonum / 100.0) * 0.5 + 0.5 * sin(u_t * 0.7); vec2 wind = p_ruzgar * (0.6 + 0.4 * sw) * 0.4;
  float k = 4.0 * t * (1.0 - t); return mix(A, B, t) + vec2(0.0, sag) * k + wind * k; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float best = 1e9; vec2 prev = ropeAt(0.0); float bt = 0.0;
  for (int i = 1; i <= 40; i++) { float t = float(i) / 40.0; vec2 p = ropeAt(t); vec2 ab = p - prev; float u = clamp(dot(q - prev, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(q - prev - ab * u); if (d < best) { best = d; bt = t; } prev = p; }
  float w = max(p_kalinlik, 0.5) * 0.5; float m = 1.0 - smoothstep(w, w + 0.8 / u_s, best); float tw = 0.85 + 0.15 * sin(bt * 120.0 + best / w * 2.0); vec3 c = c_renk * tw * (1.0 - smoothstep(0.0, w, best) * 0.35);
  o = overPre(vec4(c, 1.0) * m, s); }
