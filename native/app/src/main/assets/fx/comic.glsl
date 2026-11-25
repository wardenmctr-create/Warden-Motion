// comic
uniform float p_dot; uniform float p_edge; uniform float p_levels;
float lumAt(vec2 uv) { vec4 t = tex(uv); return luma(t.rgb) + (1.0 - t.a) * 0.0; }
vec2 sobel(vec2 uv, float r) { vec2 px = r / u_res;
  float tl = lumAt(uv + px * vec2(-1, -1)), t = lumAt(uv + px * vec2(0, -1)), tr = lumAt(uv + px * vec2(1, -1));
  float l = lumAt(uv + px * vec2(-1, 0)), rr = lumAt(uv + px * vec2(1, 0));
  float bl = lumAt(uv + px * vec2(-1, 1)), b = lumAt(uv + px * vec2(0, 1)), br = lumAt(uv + px * vec2(1, 1));
  return vec2(tr + 2.0 * rr + br - tl - 2.0 * l - bl, bl + 2.0 * b + br - tl - 2.0 * t - tr); }
float alphaEdge(vec2 uv, float r) { vec2 px = r / u_res; return abs(tex(uv + vec2(px.x, 0)).a - tex(uv - vec2(px.x, 0)).a) + abs(tex(uv + vec2(0, px.y)).a - tex(uv - vec2(0, px.y)).a); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 c = unpre(s); vec3 h = rgb2hsv(c); float lv = max(2.0, floor(p_levels)); h.z = floor(h.z * lv + 0.5) / lv; h.y = min(1.0, h.y * 1.3); c = hsv2rgb(h);
  vec2 q = rot2(45.0) * (v_uv * u_res); float sz = p_dot * u_s; vec2 cell = floor(q / sz) * sz + sz * 0.5; float rr = sqrt(clamp(1.0 - luma(c), 0.0, 1.0)) * sz * 0.5;
  float dt = 1.0 - smoothstep(rr - 0.8, rr + 0.8, length(q - cell)); c *= 1.0 - dt * 0.35;
  float e = smoothstep(0.25, 0.55, (length(sobel(v_uv, 1.3)) + alphaEdge(v_uv, 1.5)) * p_edge / 100.0); o = pre(mix(c, vec3(0.03), e), s.a);
}
