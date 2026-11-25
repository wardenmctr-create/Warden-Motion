// palettemap
uniform float p_pal; uniform float p_cycle; uniform float p_mix;
vec3 palCol(int p, int i) {
  if (p == 0) { vec3 a[5] = vec3[5](vec3(0.043,0.078,0.188), vec3(0.106,0.165,0.333), vec3(0.184,0.482,0.965), vec3(0.247,0.816,0.941), vec3(0.969,0.973,0.980)); return a[i]; }
  if (p == 1) { vec3 a[5] = vec3[5](vec3(0.17,0.04,0.2), vec3(0.55,0.11,0.35), vec3(0.91,0.26,0.36), vec3(0.98,0.56,0.27), vec3(1.0,0.86,0.5)); return a[i]; }
  if (p == 2) { vec3 a[5] = vec3[5](vec3(0.05,0.0,0.15), vec3(0.45,0.0,0.85), vec3(1.0,0.1,0.6), vec3(0.13,0.83,0.77), vec3(0.9,1.0,0.3)); return a[i]; }
  if (p == 3) { vec3 a[5] = vec3[5](vec3(0.35,0.0,0.03), vec3(0.89,0.04,0.09), vec3(0.95,0.45,0.45), vec3(0.98,0.85,0.85), vec3(1.0,1.0,1.0)); return a[i]; }
  vec3 a[5] = vec3[5](vec3(0.06,0.22,0.06), vec3(0.19,0.38,0.19), vec3(0.55,0.67,0.06), vec3(0.61,0.74,0.06), vec3(0.85,0.95,0.6)); return a[i];
}
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); float l = fract(luma(c) * 0.999 + p_cycle); int p = int(p_pal + 0.5);
  float f = l * 4.0; int i = int(floor(f)); vec3 col = mix(palCol(p, i), palCol(p, min(4, i + 1)), smoothstep(0.35, 0.65, fract(f)));
  o = pre(mix(c, col, p_mix / 100.0), s.a);
}
