// panorama
uniform sampler2D s_kaynakla, s_kaynakla_1, s_kaynakla_2; uniform float p_kaynaklaOn, p_kaynakla_1On, p_kaynakla_2On, p_dikisGeni;
vec4 img(int i, vec2 uv) { uv = clamp(uv, 0.0, 1.0); if (i == 0) return texPx(boxPx(uv)); if (i == 1) return texture(s_kaynakla, uv); if (i == 2) return texture(s_kaynakla_1, uv); return texture(s_kaynakla_2, uv); }
float meanL(int i, float x0, float x1) { float m = 0.0; for (int k = 0; k < 8; k++) m += luma(unpre(img(i, vec2(mix(x0, x1, (float(k) + 0.5) / 8.0), 0.5)))); return m / 8.0; }
void main() { int N = 1 + int(p_kaynaklaOn > 0.5) + int(p_kaynakla_1On > 0.5) + int(p_kaynakla_2On > 0.5); vec2 b = boxUV(here()); float ov = clamp(p_dikisGeni / max(boxU().x, 1.0), 0.0, 0.45);
  float span = float(N) - ov * float(N - 1); float X = b.x * span; vec4 acc = vec4(0.0); float ws = 0.0; float gain = 1.0;
  for (int i = 0; i < 4; i++) { if (i >= N) break; float x0 = float(i) * (1.0 - ov); float lx = X - x0; if (i > 0) gain *= meanL(i - 1, 1.0 - ov, 1.0) / max(meanL(i, 0.0, ov), 0.02);
    if (lx < 0.0 || lx > 1.0) continue; float w = min(1.0, min(lx / max(ov, 1e-3), (1.0 - lx) / max(ov, 1e-3))); if (i == 0) w = max(w, step(lx, 0.5)); if (i == N - 1) w = max(w, step(0.5, lx));
    vec2 uv = vec2(lx, 0.5 + (b.y - 0.5) * span * boxU().y / boxU().x * 0.0 + (b.y - 0.5)); vec4 c = img(i, uv); c.rgb = clamp(c.rgb * gain, 0.0, c.a); acc += c * w; ws += w; }
  o = ws > 0.0 ? acc / ws : vec4(0.0); }
