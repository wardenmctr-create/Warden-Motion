// densitycontour
uniform sampler2D s_yogunluk; uniform float p_yogunlukOn, p_seviye, p_yumusatm, p_dolguBant;
// Yumuşatılmış yoğunluk (kaynak alfa ya da koyuluk) eş değer eğrileri; isteğe bağlı renkli bantlar
float D(vec2 px) { if (p_yogunlukOn > 0.5) return texture(s_yogunluk, boxUV(px)).a; vec4 c = texPx(px); return (1.0 - luma(unpre(c))) * c.a; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float R = max(p_yumusatm * u_s, 1.0); float d = 0.0, w = 0.0; for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { float g = exp(-float(i * i + j * j) / 8.0); d += D(p + vec2(i, j) / 3.0 * R) * g; w += g; } d /= w;
  float N = max(p_seviye, 2.0); float f = d * N; float fw = fwidth(f) + 1e-4; float line = 1.0 - smoothstep(0.0, fw * 1.5, abs(fract(f + 0.5) - 0.5));
  vec4 res = s; if (p_dolguBant > 0.5) res = vec4(hsv2rgb(vec3(0.66 - floor(f) / N * 0.66, 0.6, 0.95)), 1.0); o = overPre(vec4(0.05, 0.05, 0.08, 1.0) * line, res); }
