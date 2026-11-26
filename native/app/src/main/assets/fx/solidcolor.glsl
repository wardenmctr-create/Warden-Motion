// solidcolor
uniform vec3 c_dolguReng; uniform float p_renkOpak, p_kaynakAlfaKoru;
void main() {
  vec4 s = texture(u_tex, v_uv); float a = p_kaynakAlfaKoru > 0.5 ? s.a : (boxUV(here()) == clamp(boxUV(here()), 0.0, 1.0) ? 1.0 : 0.0);
  o = mix(s, pre(c_dolguReng, a), p_renkOpak / 100.0);
}
