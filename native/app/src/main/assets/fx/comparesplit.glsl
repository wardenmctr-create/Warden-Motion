// comparesplit
uniform sampler2D s_ikinciKatm; uniform float p_ikinciKatmOn, p_ayirici, p_cizgiKali, p_ayiriciYonu; uniform vec3 c_cizgiReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 o2 = p_ikinciKatmOn > 0.5 ? texture(s_ikinciKatm, clamp(b, 0.0, 1.0)) : vec4(vec3(luma(unpre(s))) * s.a, s.a); float x = p_ayiriciYonu < 0.5 ? b.x : p_ayiriciYonu < 1.5 ? b.y : (b.x + b.y) * 0.5;
  float k = p_ayirici / 100.0; vec4 c = x < k ? s : o2; float line = 1.0 - smoothstep(p_cizgiKali / max(boxU().x, 1.0) * 0.5, p_cizgiKali / max(boxU().x, 1.0) * 0.5 + 0.002, abs(x - k)); o = overPre(vec4(c_cizgiReng, 1.0) * line, c); }
