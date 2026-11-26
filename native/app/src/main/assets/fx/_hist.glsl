// Zamansal efektlerin kare şeridi: s_hist içinde N kare yan yana (motor: Renderer.historySource, sıra: History.kt)
uniform sampler2D s_hist;
float histN() { ivec2 a = textureSize(s_hist, 0); if (a.y <= 1) return 0.0; return floor(float(a.x) / float(a.y) * u_res.y / u_res.x + 0.5); }
vec4 hist(float k, vec2 uv) { float n = max(histN(), 1.0); return texture(s_hist, vec2((clamp(k, 0.0, n - 1.0) + clamp(uv.x, 0.0, 1.0)) / n, clamp(uv.y, 0.0, 1.0))); }
