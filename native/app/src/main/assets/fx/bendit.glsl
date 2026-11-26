// bendit
uniform vec2 p_baslangi, p_bitis; uniform float p_bukulmeAcis, p_bukumYonu, p_genisligKoru;
void main() {
  vec2 q = toUnit(here()); vec2 A = p_baslangi, Bp = p_bitis; vec2 ax = Bp - A; float L = max(length(ax), 1.0); vec2 d = ax / L;
  float th = radians(p_bukulmeAcis); vec2 n = vec2(-d.y, d.x) * (cos(radians(p_bukumYonu)) >= 0.0 ? 1.0 : -1.0);
  if (th < 0.0) { th = -th; n = -n; }
  if (th < 1e-3 || dot(q - A, d) < 0.0) { o = texU(q); return; }
  float R = L / th; vec2 C = A + n * R; vec2 rel = q - C;
  float phi = atan(dot(rel, d), dot(rel, -n));
  vec2 src;
  if (phi >= 0.0 && phi <= th) { float t = R - length(rel); src = A + d * phi * R + n * t; }
  else {
    vec2 E = C + (-n * cos(th) + d * sin(th)) * R; vec2 d2 = d * cos(th) + n * sin(th); vec2 n2 = vec2(-d2.y, d2.x) * sign(dot(vec2(-d.y, d.x), n));
    vec2 lr = q - E; float u = dot(lr, d2), v = dot(lr, n2);
    if (u < 0.0) { o = vec4(0.0); return; }
    src = Bp + d * u + n * v * sign(dot(n2, n));
  }
  o = texU(src);
}
