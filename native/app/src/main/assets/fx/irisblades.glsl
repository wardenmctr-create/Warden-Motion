// irisblades
uniform float p_yaprakSayi, p_ilerleme, p_kivrim;
void main() { vec4 s = texture(u_tex, v_uv); float p = p_ilerleme / 100.0; vec2 q = (boxUV(here()) - 0.5) * boxU() / (length(boxU()) * 0.5); float N = max(floor(p_yaprakSayi), 3.0); float a = atan(q.y, q.x) + p * 1.2;
  float sec = TAU / N; float la = mod(a, sec) - sec * 0.5; float r = length(q) * cos(la) * (1.0 + p_kivrim / 300.0 * sin(la * 3.0)); float open_ = 1.0 - p; float m = step(r, open_ * 1.05);
  float bladeEdge = 1.0 - smoothstep(0.0, 0.01, abs(r - open_)) ; o = overPre(vec4(0.15, 0.15, 0.17, 1.0) * bladeEdge * step(0.001, p) * step(p, 0.999), s * m); }
