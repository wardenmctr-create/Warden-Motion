// halftone
uniform float p_size; uniform float p_ang; uniform float p_mode; uniform vec3 c_bg;
float dotAt(vec2 px, float ang, float val) { vec2 q = rot2(ang) * px; float sz = p_size * u_s; vec2 cell = floor(q / sz) * sz + sz * 0.5; float r = sqrt(clamp(val, 0.0, 1.0)) * sz * 0.72; return 1.0 - smoothstep(r - 1.0, r + 1.0, length(q - cell)); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 px = v_uv * u_res; vec3 c = unpre(s); int m = int(p_mode + 0.5); vec3 col;
  if (m == 1) { col = mix(c_bg, vec3(0.04, 0.05, 0.1), dotAt(px, p_ang, 1.0 - luma(c))); }
  else if (m == 2) { col = mix(c_bg, c, dotAt(px, p_ang, 1.0 - luma(c) * 0.8)); }
  else { vec3 cmy = 1.0 - c; col = c_bg;
    col -= vec3(1, 0, 0) * dotAt(px, p_ang + 15.0, cmy.r) * 0.9; col -= vec3(0, 1, 0) * dotAt(px, p_ang + 75.0, cmy.g) * 0.9; col -= vec3(0, 0, 1) * dotAt(px, p_ang, cmy.b) * 0.9; col = clamp(col, 0.0, 1.0); }
  o = pre(col, s.a);
}
