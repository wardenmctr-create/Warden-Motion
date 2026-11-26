// motiondirmatte
INCLUDE(_hist)
uniform float p_yon, p_aciTole, p_asgariHiz, p_akisYumu;
void main() { vec4 s = texture(u_tex, v_uv); if (histN() < 3.0) { o = s; return; } vec2 px = 1.0 / u_res; float r = max(p_akisYumu, 1.0); mat2 A = mat2(0.0); vec2 bvec = vec2(0.0);
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 uv = v_uv + vec2(i, j) * px * r; float Ix = (luma(hist(0.0, uv + vec2(px.x, 0.0)).rgb) - luma(hist(0.0, uv - vec2(px.x, 0.0)).rgb)) * 0.5; float Iy = (luma(hist(0.0, uv + vec2(0.0, px.y)).rgb) - luma(hist(0.0, uv - vec2(0.0, px.y)).rgb)) * 0.5;
    float It = (luma(hist(2.0, uv).rgb) - luma(hist(1.0, uv).rgb)) * 0.5; A += mat2(Ix * Ix, Ix * Iy, Ix * Iy, Iy * Iy); bvec += vec2(Ix * It, Iy * It); }
  float det = A[0][0] * A[1][1] - A[0][1] * A[1][0]; vec2 v = abs(det) > 1e-6 ? -inverse(A) * bvec : vec2(0.0); float sp = length(v) / max(u_s, 0.1) * 30.0; float ang = degrees(atan(v.y, v.x)); float d = abs(mod(ang - p_yon + 540.0, 360.0) - 180.0);
  float m = step(p_asgariHiz * 0.1, sp) * (1.0 - smoothstep(p_aciTole, p_aciTole + 10.0, d)); o = pre(unpre(s), s.a * m); }
