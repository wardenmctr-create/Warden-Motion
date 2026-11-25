// cartoon
uniform float p_levels; uniform float p_edge;
float lumAt(vec2 uv) { vec4 t = tex(uv); return luma(t.rgb) + (1.0 - t.a) * 0.0; }
vec2 sobel(vec2 uv, float r) { vec2 px = r / u_res;
  float tl = lumAt(uv + px * vec2(-1, -1)), t = lumAt(uv + px * vec2(0, -1)), tr = lumAt(uv + px * vec2(1, -1));
  float l = lumAt(uv + px * vec2(-1, 0)), rr = lumAt(uv + px * vec2(1, 0));
  float bl = lumAt(uv + px * vec2(-1, 1)), b = lumAt(uv + px * vec2(0, 1)), br = lumAt(uv + px * vec2(1, 1));
  return vec2(tr + 2.0 * rr + br - tl - 2.0 * l - bl, bl + 2.0 * b + br - tl - 2.0 * t - tr); }
float alphaEdge(vec2 uv, float r) { vec2 px = r / u_res; return abs(tex(uv + vec2(px.x, 0)).a - tex(uv - vec2(px.x, 0)).a) + abs(tex(uv + vec2(0, px.y)).a - tex(uv - vec2(0, px.y)).a); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec3 acc = vec3(0.0); float n = 0.0;
  for (int y = -2; y <= 2; y++) for (int x = -2; x <= 2; x++) { vec4 t = tex(v_uv + vec2(x, y) * 1.5 / u_res); if (t.a > 0.0) { acc += unpre(t); n += 1.0; } }
  vec3 c = acc / max(1.0, n); float lv = max(2.0, floor(p_levels)); vec3 h = rgb2hsv(c); h.z = floor(h.z * lv + 0.5) / lv; h.y = min(1.0, h.y * 1.15); c = hsv2rgb(h);
  float e = smoothstep(0.25, 0.6, (length(sobel(v_uv, 1.2)) + alphaEdge(v_uv, 1.2)) * p_edge / 100.0);
  o = pre(mix(c, vec3(0.05, 0.05, 0.08), e), s.a);
}
