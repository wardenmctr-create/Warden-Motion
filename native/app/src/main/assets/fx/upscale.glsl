// upscale
uniform float p_scale; uniform float p_detail; uniform float p_noise;
void main() { vec2 c = boxCenter(); float k = p_scale / 100.0; vec2 src = c + (v_uv * u_res - c) / k; vec2 uv = src / u_res; vec2 d = 1.0 / u_res;
  vec4 s = tex(uv); vec4 bl = (tex(uv + vec2(d.x, 0)) + tex(uv - vec2(d.x, 0)) + tex(uv + vec2(0, d.y)) + tex(uv - vec2(0, d.y))) * 0.25;
  if (s.a <= 0.0) { o = s; return; } vec3 col = mix(unpre(s), unpre(bl), p_noise / 100.0 * 0.5); col += (unpre(s) - unpre(bl)) * p_detail / 100.0 * 1.2; o = pre(clamp(col, 0.0, 1.0), s.a); }
