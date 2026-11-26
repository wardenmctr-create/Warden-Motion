// treerings
uniform vec2 p_merkez; uniform float p_halkaAral, p_duzensiz;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float a = atan(q.y, q.x); float r = length(q) + fbm(vec2(a * 2.0, length(q) * 0.02), 3.0) * p_duzensiz * 0.6; float ring = fract(r / max(p_halkaAral, 1.0));
  float late = smoothstep(0.7, 0.95, ring); vec3 c = mix(vec3(0.82, 0.62, 0.38), vec3(0.55, 0.35, 0.18), late) * (0.9 + 0.1 * vnoise(vec2(a * 30.0, r * 0.3))); o = pre(c, s.a); }
