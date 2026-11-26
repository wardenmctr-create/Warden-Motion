// eyedropper
uniform sampler2D s_kaynakKatm; uniform float p_kaynakKatmOn; uniform vec2 p_ornekNokt; uniform float p_ornekYari, p_dolguOpak, p_alfayiKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); vec4 acc = vec4(0.0); float R = p_ornekYari * u_s;
  for (int i = 0; i < 9; i++) { vec2 d = vec2(float(i % 3) - 1.0, float(i / 3) - 1.0) * R * 0.7;
    acc += p_kaynakKatmOn > 0.5 ? texture(s_kaynakKatm, clamp(boxUV(fromUnit(p_ornekNokt) + d), 0.0, 1.0)) : texPx(fromUnit(p_ornekNokt) + d); }
  acc /= 9.0; vec3 col = unpre(acc); float a = p_alfayiKoru > 0.5 ? s.a : 1.0;
  o = mix(s, pre(col, a), p_dolguOpak / 100.0);
}
