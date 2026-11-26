// vrcombined
uniform float p_yatayBaki, p_dikeyBaki, p_yuvarlan, p_gorusAcis, p_renkSaca, p_projeksi, p_kenarYumu;
vec2 look(vec2 b, float fovAdd) {
  vec2 B = boxU(); float asp = B.x / B.y; vec2 p = (b - 0.5) * 2.0 * vec2(asp, 1.0); float f = radians(clamp(p_gorusAcis + fovAdd, 10.0, 170.0)) * 0.5;
  vec3 dir;
  if (p_projeksi < 0.5) dir = normalize(vec3(p * tan(f), 1.0));
  else { float r = length(p) * f; vec2 u = length(p) > 1e-5 ? normalize(p) : vec2(0.0); dir = vec3(u * sin(r), cos(r)); }
  float ro = radians(p_yuvarlan), pi_ = radians(p_dikeyBaki), ya = radians(p_yatayBaki);
  dir.xy = mat2(cos(ro), sin(ro), -sin(ro), cos(ro)) * dir.xy;
  dir.yz = mat2(cos(pi_), sin(pi_), -sin(pi_), cos(pi_)) * dir.yz;
  dir.xz = mat2(cos(ya), -sin(ya), sin(ya), cos(ya)) * dir.xz;
  return vec2(fract(atan(dir.x, dir.z) / TAU + 0.5), asin(clamp(dir.y, -1.0, 1.0)) / PI + 0.5);
}
void main() {
  vec2 b = boxUV(here()); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) { o = vec4(0.0); return; }
  float ca = p_renkSaca * 0.15;
  vec4 g = texPx(boxPx(clamp(look(b, 0.0), 0.001, 0.999)));
  o = vec4(texPx(boxPx(clamp(look(b, ca), 0.001, 0.999))).r, g.g, texPx(boxPx(clamp(look(b, -ca), 0.001, 0.999))).b, g.a);
}
