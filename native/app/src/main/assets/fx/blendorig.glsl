// blendorig
uniform sampler2D u_src; uniform float p_karisim, p_mod, p_kaynak, p_alfaKoru;
void main() { vec4 s = texture(u_tex, v_uv); vec4 orig = texture(u_src, v_uv); vec3 a = unpre(s), b = unpre(orig); vec3 r = p_mod < 0.5 ? b : p_mod < 1.5 ? a * b : p_mod < 2.5 ? screenB(a, b) : p_mod < 3.5 ? overlayB(a, b) : abs(a - b);
  vec3 c = mix(a, r, p_karisim / 100.0); o = pre(c, p_alfaKoru > 0.5 ? s.a : mix(s.a, orig.a, p_karisim / 100.0)); }
