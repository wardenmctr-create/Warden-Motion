// sketch
uniform float p_amount; uniform float p_detail; uniform float p_mix;
float lumAt(vec2 uv) { vec4 t = tex(uv); return luma(t.rgb) + (1.0 - t.a) * 0.0; }
vec2 sobel(vec2 uv, float r) { vec2 px = r / u_res;
  float tl = lumAt(uv + px * vec2(-1, -1)), t = lumAt(uv + px * vec2(0, -1)), tr = lumAt(uv + px * vec2(1, -1));
  float l = lumAt(uv + px * vec2(-1, 0)), rr = lumAt(uv + px * vec2(1, 0));
  float bl = lumAt(uv + px * vec2(-1, 1)), b = lumAt(uv + px * vec2(0, 1)), br = lumAt(uv + px * vec2(1, 1));
  return vec2(tr + 2.0 * rr + br - tl - 2.0 * l - bl, bl + 2.0 * b + br - tl - 2.0 * t - tr); }
float alphaEdge(vec2 uv, float r) { vec2 px = r / u_res; return abs(tex(uv + vec2(px.x, 0)).a - tex(uv - vec2(px.x, 0)).a) + abs(tex(uv + vec2(0, px.y)).a - tex(uv - vec2(0, px.y)).a); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float e = length(sobel(v_uv, p_detail)) + alphaEdge(v_uv, p_detail) * 0.5; float l = luma(unpre(s));
  vec2 px = v_uv * u_res; float hatch = 0.0;
  if (l < 0.75) hatch += step(0.5, fract((px.x + px.y) / (3.0 * u_s))) * 0.15;
  if (l < 0.45) hatch += step(0.5, fract((px.x - px.y) / (3.0 * u_s))) * 0.15;
  float paper = 0.96 + hash1(floor(px / 2.0)) * 0.04;
  float v = clamp(paper - e * p_amount / 100.0 * 1.2 - hatch, 0.0, 1.0);
  o = pre(mix(unpre(s), vec3(v * 0.98, v * 0.97, v * 0.95), p_mix / 100.0), s.a);
}
