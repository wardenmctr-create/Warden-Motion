// shadowcatcher
INCLUDE(_3d)
INCLUDE(_card)
uniform sampler2D s_isikMode; uniform float p_isikModeOn, p_golgeGucu, p_zeminGizl;
float sdf(vec3 p) { return cardD(p, 14.0); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { vec4 c = render3d(vec3(0.0)); vec4 s = texture(u_tex, v_uv); float objA = s.a; vec4 sh = vec4(0.0, 0.0, 0.0, 1.0) * clamp((c.a - objA) * p_golgeGucu / 100.0 * 1.5, 0.0, 1.0); if (luma(c.rgb / max(c.a, 1e-3)) > 0.05) sh *= step(objA, 0.01);
  o = p_zeminGizl > 0.5 ? sh : overPre(sh, vec4(0.9, 0.92, 0.95, 1.0)); }
