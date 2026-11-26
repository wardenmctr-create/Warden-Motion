// kernelfilter
uniform float p_matrisBoyu, p_normaliz, p_katsayilN; uniform float p_katsayil[225];
void main() { vec4 s = texture(u_tex, v_uv); int N = int(clamp(floor(p_matrisBoyu), 1.0, 15.0)); if (N % 2 == 0) N -= 1; int n = int(sqrt(max(p_katsayilN, 1.0)) + 0.5); int K = min(N, n); int h = K / 2;
  vec4 acc = vec4(0.0); float sum = 0.0; for (int j = 0; j < 15; j++) for (int i = 0; i < 15; i++) { if (i >= K || j >= K) continue; float w = p_katsayil[j * n + i]; acc += texPx(here() + vec2(i - h, j - h) * u_s) * w; sum += w; }
  if (p_normaliz > 0.5 && abs(sum) > 1e-4) acc /= sum; o = p_katsayilN < 1.0 ? s : vec4(clamp(acc.rgb, 0.0, 1.0), clamp(acc.a, 0.0, 1.0)); }
