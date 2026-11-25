// vegas
uniform float p_count; uniform float p_width; uniform float p_speed; uniform vec3 c_col; uniform float p_on;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 px = v_uv * u_res; float w = p_width * u_s; float edge;
  if (p_on > 0.5) { vec2 d = min(px - u_box.xy, u_box.xy + u_box.zw - px); edge = 1.0 - smoothstep(w * 0.5, w, abs(min(d.x, d.y))); }
  else { float a = s.a; float e = abs(tex(v_uv + vec2(w, 0) / u_res).a - tex(v_uv - vec2(w, 0) / u_res).a) + abs(tex(v_uv + vec2(0, w) / u_res).a - tex(v_uv - vec2(0, w) / u_res).a); edge = clamp(e, 0.0, 1.0); }
  vec2 c = px - boxCenter(); float ang = atan(c.y, c.x) / TAU + 0.5; float seg = fract(ang * p_count - u_t * p_speed);
  float on = smoothstep(0.0, 0.1, seg) * (1.0 - smoothstep(0.45, 0.6, seg));
  float k = edge * on; vec3 col = mix(c_col, vec3(1.0), 0.35);
  o = s * (1.0 - k) + vec4(col, 1.0) * k;
}
