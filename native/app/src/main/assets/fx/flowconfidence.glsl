// flowconfidence
INCLUDE(_hist)
uniform float p_ileriGeriHata, p_dokuEsig, p_cikti, p_yumusatm;
// Lucas-Kanade akışı kare t→t+1 ve t+1→t; ileri-geri hata ve doku (gradyan enerjisi) güveni belirler
vec2 lk(float a, float b2, vec2 uv) { vec2 px = 1.0 / u_res; mat2 A = mat2(0.0); vec2 bb = vec2(0.0); float r = max(p_yumusatm, 1.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 q = uv + vec2(i, j) * px * r; float Ix = (luma(hist(a, q + vec2(px.x, 0.0)).rgb) - luma(hist(a, q - vec2(px.x, 0.0)).rgb)) * 0.5;
    float Iy = (luma(hist(a, q + vec2(0.0, px.y)).rgb) - luma(hist(a, q - vec2(0.0, px.y)).rgb)) * 0.5; float It = luma(hist(b2, q).rgb) - luma(hist(a, q).rgb); A += mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy); bb += vec2(Ix * It, Iy * It); }
  float det = A[0][0] * A[1][1] - A[0][1] * A[1][0]; return abs(det) > 1e-7 ? -inverse(A) * bb : vec2(0.0); }
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 3.0) { o = s; return; } vec2 f = lk(0.0, 2.0, v_uv); vec2 bk = lk(2.0, 0.0, v_uv + f / u_res); float err = length(f + bk);
  float tex2 = length(lumGrad(here(), 1.0)) * 4.0; float conf = (1.0 - smoothstep(p_ileriGeriHata * 0.5, p_ileriGeriHata * 1.5, err)) * smoothstep(p_dokuEsig / 100.0 * 0.5, p_dokuEsig / 100.0, tex2);
  float v = p_cikti < 0.5 ? conf : 1.0 - conf; o = vec4(vec3(v) * s.a, s.a); }
