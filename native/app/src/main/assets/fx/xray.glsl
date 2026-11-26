// xray
uniform vec3 c_ton; uniform float p_terslik, p_kontrast, p_kenarVurg, p_alfayiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float l = luma(c);
  l = mix(l, 1.0 - l, p_terslik / 100.0); l = (l - 0.5) * (1.0 + p_kontrast / 100.0) + 0.5;
  vec2 e = vec2(1.0) ; float ed = abs(luma(unpre(texPx(here() + vec2(e.x, 0.0)))) - luma(unpre(texPx(here() - vec2(e.x, 0.0))))) + abs(luma(unpre(texPx(here() + vec2(0.0, e.y)))) - luma(unpre(texPx(here() - vec2(0.0, e.y)))));
  l += ed * p_kenarVurg / 100.0 * 2.0;
  vec3 r = clamp(c_ton * l * 1.1 + pow(max(l, 0.0), 3.0) * 0.3, 0.0, 1.0);
  o = pre(r, p_alfayiKoru > 0.5 ? s.a : max(s.a, l * 0.0 + 1.0) * step(0.0, boxUV(here()).x) * step(boxUV(here()).x, 1.0) * step(0.0, boxUV(here()).y) * step(boxUV(here()).y, 1.0));
}
