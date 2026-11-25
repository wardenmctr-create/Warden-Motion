// repetile: kutunun dışına tekrar / ayna / uzatma
uniform float p_l; uniform float p_r; uniform float p_u; uniform float p_d; uniform float p_mode;
void main() {
  vec2 px = v_uv * u_res; vec2 b0 = u_box.xy, sz = u_box.zw;
  if (px.x < b0.x - p_l * u_s || px.x > b0.x + sz.x + p_r * u_s || px.y < b0.y - p_u * u_s || px.y > b0.y + sz.y + p_d * u_s) { o = vec4(0.0); return; }
  vec2 q = (px - b0) / sz; int m = int(p_mode + 0.5);
  if (m == 0) q = fract(q); else if (m == 1) { q = abs(mod(q, 2.0)); q = mix(q, 2.0 - q, step(1.0, q)); } else q = clamp(q, 0.001, 0.999);
  o = texPx(b0 + q * sz);
}
