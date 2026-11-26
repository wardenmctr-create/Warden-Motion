// roundcorners
uniform float p_yaricap, p_solUst, p_sagUst, p_solAlt, p_sagAlt, p_koseleriBagl, p_yumusatm;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU() * 0.5;
  vec4 r4 = p_koseleriBagl > 0.5 ? vec4(p_yaricap) : vec4(p_sagUst, p_sagAlt, p_solUst, p_solAlt);
  float r = q.x > 0.0 ? (q.y > 0.0 ? r4.y : r4.x) : (q.y > 0.0 ? r4.w : r4.z); r = min(r, min(B.x, B.y));
  vec2 d2 = abs(q) - B + r; float d = length(max(d2, 0.0)) + min(max(d2.x, d2.y), 0.0) - r; float w = max(p_yumusatm, 0.5 / u_s);
  o = s * (1.0 - smoothstep(-w, w, d));
}
