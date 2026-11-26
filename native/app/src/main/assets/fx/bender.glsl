// bender
uniform vec2 p_sabitUc, p_serbestUc; uniform float p_kavisAcis, p_kavisDagi, p_kalinligKoru;
void main() {
  vec2 q = toUnit(here()); vec2 A = p_sabitUc; vec2 ax = p_serbestUc - A; float L = max(length(ax), 1.0); vec2 d = ax / L; vec2 n = vec2(-d.y, d.x);
  float s = dot(q - A, d), m = dot(q - A, n);
  if (s <= 0.0) { o = texU(q); return; }
  // Bükülme kümülatif: açı s boyunca dağılır; geriye doğru yaklaşık ters eşleme (iteratif)
  float th = radians(p_kavisAcis); float ex = mix(0.4, 2.5, p_kavisDagi / 100.0);
  vec2 cur = A; float su = 0.0; vec2 best = q; float bd = 1e9; const int N = 48;
  for (int i = 0; i < N; i++) {
    float u = (float(i) + 0.5) / float(N); float ang = th * pow(u, ex);
    vec2 dd = d * cos(ang) + n * sin(ang); vec2 nn = vec2(-dd.y, dd.x);
    vec2 seg = cur + dd * (L / float(N)) * 0.5;
    vec2 rel = q - seg; float along = dot(rel, dd), perp = dot(rel, nn);
    float dist = abs(along) - L / float(N) * 0.5;
    float sc = max(dist, 0.0) + abs(perp) * 0.001;
    if (abs(along) <= L / float(N) * 0.5 + 0.01 && abs(perp) < bd) { bd = abs(perp); best = A + d * (u * L + along) + n * perp; }
    cur += dd * (L / float(N));
  }
  if (bd > 1e8) { // serbest ucun ötesi: son yönde düz devam
    float ang = th; vec2 dd = d * cos(ang) + n * sin(ang); vec2 nn = vec2(-dd.y, dd.x);
    vec2 rel = q - cur; float along = dot(rel, dd); if (along < 0.0) { o = vec4(0.0); return; } best = p_serbestUc + d * along + n * dot(rel, nn);
  }
  o = texU(best);
}
