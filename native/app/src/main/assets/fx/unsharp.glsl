// unsharp
uniform sampler2D u_aux; uniform float p_amount; uniform float p_thr;
void main() { vec4 s = texture(u_tex, v_uv), b = texture(u_aux, v_uv); if (s.a <= 0.0) { o = s; return; } vec3 c = unpre(s), d = c - unpre(b);
  float m = step(p_thr / 255.0, max(abs(d.r), max(abs(d.g), abs(d.b)))); o = pre(clamp(c + d * p_amount / 100.0 * m, 0.0, 1.0), s.a); }
