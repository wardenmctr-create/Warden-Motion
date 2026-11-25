// blockload
uniform float p_prog; uniform float p_scan;
void main() {
  float pr = p_prog / 100.0; vec2 px = v_uv * u_res; float maxB = 64.0 * u_s;
  float stage = pr * 5.0; float bsz = max(1.0, maxB / pow(2.0, floor(stage)));
  vec2 cell = floor((px - u_box.xy) / bsz) * bsz + u_box.xy + bsz * 0.5; vec4 c = tex(cell / u_res);
  if (stage >= 5.0) c = texture(u_tex, v_uv);
  float rowp = fract(stage); float vis = 1.0; if (p_scan > 0.5 && stage < 5.0) { float y = boxUV(px).y; vis = step(y, rowp + (floor(stage) > 0.0 ? 1.0 : 0.0)); }
  o = c * vis;
}
