// texturize
uniform float p_tex; uniform float p_amount; uniform float p_scale;
float texH(vec2 p, int t) {
  if (t == 0) return 0.5 + 0.25 * (sin(p.x * 6.0) * sin(p.y * 6.0)) + 0.15 * vnoise(p * 8.0);
  if (t == 1) return fbm(p * 3.0, 4.0) * 0.5 + 0.5;
  if (t == 2) { vec2 q = vec2(p.x + (mod(floor(p.y * 2.0), 2.0) * 0.5), p.y * 2.0); vec2 f = fract(q); return min(smoothstep(0.0, 0.06, f.x) * smoothstep(1.0, 0.94, f.x), smoothstep(0.0, 0.1, f.y) * smoothstep(1.0, 0.9, f.y)) * 0.6 + vnoise(p * 20.0) * 0.3; }
  if (t == 3) return 0.5 + 0.3 * (step(0.5, fract(p.x * 8.0)) == step(0.5, fract(p.y * 8.0)) ? 1.0 : -1.0) * 0.5 + vnoise(p * 40.0) * 0.15;
  return vnoise(p * 10.0) * 0.6 + vnoise(p * 40.0) * 0.4;
}
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 p = v_uv * u_res / (p_scale * u_s); int t = int(p_tex + 0.5); float e = 0.01;
  float hx = texH(p + vec2(e, 0), t) - texH(p - vec2(e, 0), t), hy = texH(p + vec2(0, e), t) - texH(p - vec2(0, e), t);
  float sh = clamp(0.5 + (hx * -0.7 + hy * -0.7) * 20.0, 0.0, 1.0);
  vec3 c = unpre(s) * mix(1.0, 0.6 + sh * 0.8, p_amount / 100.0); o = pre(clamp(c, 0.0, 1.0), s.a);
}
