// cornerpin
uniform vec2 p_solUst, p_sagUst, p_solAlt, p_sagAlt; uniform float p_perspektDuze, p_kenarModu;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU();
  vec2 q0 = p_solUst, q1 = p_sagUst, q2 = p_sagAlt, q3 = p_solAlt;
  float sx = q0.x - q1.x + q2.x - q3.x, sy = q0.y - q1.y + q2.y - q3.y;
  float a, b, c, d, e, f, g, h;
  if (p_perspektDuze < 0.5 || (abs(sx) < 1e-4 && abs(sy) < 1e-4)) { a = q1.x - q0.x; b = q3.x - q0.x; c = q0.x; d = q1.y - q0.y; e = q3.y - q0.y; f = q0.y; g = 0.0; h = 0.0; }
  else {
    float dx1 = q1.x - q2.x, dx2 = q3.x - q2.x, dy1 = q1.y - q2.y, dy2 = q3.y - q2.y; float det = dx1 * dy2 - dx2 * dy1;
    g = (sx * dy2 - dx2 * sy) / det; h = (dx1 * sy - sx * dy1) / det;
    a = q1.x - q0.x + g * q1.x; b = q3.x - q0.x + h * q3.x; c = q0.x; d = q1.y - q0.y + g * q1.y; e = q3.y - q0.y + h * q3.y; f = q0.y;
  }
  mat3 H = mat3(a, d, g, b, e, h, c, f, 1.0);
  vec3 uv = inverse(H) * vec3(q, 1.0); vec2 st = uv.xy / uv.z;
  if (p_kenarModu < 0.5 && (any(lessThan(st, vec2(0.0))) || any(greaterThan(st, vec2(1.0))))) { o = vec4(0.0); return; }
  o = texPx(boxPx(clamp(st, 0.0, 1.0)));
}
