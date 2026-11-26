// scribble
uniform float p_cizgiKali, p_aci, p_cizgiAral, p_kivrim, p_rastgele, p_ilerleme, p_tohum; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()); float sp = max(p_cizgiAral, 1.0);
  float row = floor(q.y / sp + 0.5); float y = q.y - row * sp;
  float wob = sin(q.x / max(p_kivrim * 4.0, 1.0) + row * 1.7 + seedf(p_tohum)) * p_kivrim * 0.5 * (0.5 + p_rastgele / 100.0) + (vnoise(vec2(q.x * 0.05, row + seedf(p_tohum))) - 0.5) * p_rastgele / 100.0 * sp;
  float d = abs(y - wob); float line = 1.0 - smoothstep(p_cizgiKali * 0.5 - 0.5, p_cizgiKali * 0.5 + 0.5, d);
  vec2 B = boxU(); float prog = (row * sp / B.y + 0.5); float shown = step(prog, p_ilerleme / 100.0 * 1.02);
  o = vec4(c_renk, 1.0) * line * s.a * shown;
}
