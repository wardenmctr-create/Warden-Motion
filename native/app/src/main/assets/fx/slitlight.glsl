// slitlight
uniform vec2 p_kaynak; uniform float p_yarikGeni, p_projeksi, p_kenarPenu;
// Işık kaynağından kutu merkezindeki yarıktan geçen kama; projeksiyon boyunca uzar, iki kenarı yarı gölgeli
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 S = p_kaynak; vec2 C = vec2(0.0); vec2 ax = normalize(C - S + vec2(1e-4)); vec2 nr = vec2(-ax.y, ax.x);
  float along = dot(q - C, ax); float across = dot(q - C, nr); float dist = length(C - S); float halfw = p_yarikGeni * 0.5 * (1.0 + max(along, 0.0) / max(dist, 1.0));
  float pen = p_kenarPenu * (0.3 + max(along, 0.0) / max(dist, 1.0)) + 0.5; float wedge = (1.0 - smoothstep(halfw - pen, halfw + pen, abs(across))) * smoothstep(-2.0, 2.0, along) * (1.0 - smoothstep(p_projeksi * 0.8, p_projeksi, along));
  vec3 c = s.rgb * (0.45 + 0.9 * wedge); o = vec4(c, s.a); }
