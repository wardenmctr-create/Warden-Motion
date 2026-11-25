// glass
uniform float p_amount; uniform float p_size; uniform float p_tex; uniform float p_shine;
float h(vec2 p) { int t = int(p_tex + 0.5); if (t == 0) return fbm(p, 3.0); if (t == 1) return sin(p.x * 2.0 + sin(p.y * 1.3) * 1.5) * 0.5; if (t == 2) { vec2 f = fract(p) - 0.5; return 0.5 - max(abs(f.x), abs(f.y)); } vec2 f = fract(p) - 0.5; return 0.4 - length(f); }
void main() {
  vec2 px = v_uv * u_res; vec2 q = px / (p_size * u_s); float e = 0.02;
  vec2 g = vec2(h(q + vec2(e, 0)) - h(q - vec2(e, 0)), h(q + vec2(0, e)) - h(q - vec2(0, e))) / (2.0 * e);
  vec4 s = tex(v_uv + g * p_amount * u_s / u_res * 0.6);
  float sp = pow(max(0.0, dot(normalize(vec3(-g, 1.0)), normalize(vec3(-0.5, -0.6, 1.0)))), 24.0) * p_shine / 100.0;
  o = s + vec4(vec3(sp), 0.0) * s.a;
}
