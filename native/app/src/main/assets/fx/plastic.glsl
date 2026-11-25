// plastic
uniform float p_height; uniform float p_ang; uniform float p_gloss; uniform float p_soft;
float lumAt(vec2 uv) { vec4 t = tex(uv); return luma(t.rgb) + (1.0 - t.a) * 0.0; }
vec2 sobel(vec2 uv, float r) { vec2 px = r / u_res;
  float tl = lumAt(uv + px * vec2(-1, -1)), t = lumAt(uv + px * vec2(0, -1)), tr = lumAt(uv + px * vec2(1, -1));
  float l = lumAt(uv + px * vec2(-1, 0)), rr = lumAt(uv + px * vec2(1, 0));
  float bl = lumAt(uv + px * vec2(-1, 1)), b = lumAt(uv + px * vec2(0, 1)), br = lumAt(uv + px * vec2(1, 1));
  return vec2(tr + 2.0 * rr + br - tl - 2.0 * l - bl, bl + 2.0 * b + br - tl - 2.0 * t - tr); }
float alphaEdge(vec2 uv, float r) { vec2 px = r / u_res; return abs(tex(uv + vec2(px.x, 0)).a - tex(uv - vec2(px.x, 0)).a) + abs(tex(uv + vec2(0, px.y)).a - tex(uv - vec2(0, px.y)).a); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 g = sobel(v_uv, max(1.0, p_soft / 10.0 * u_s)) * p_height; vec3 n = normalize(vec3(-g, 1.0));
  vec3 L = normalize(vec3(cos(radians(p_ang)), sin(radians(p_ang)), 0.8));
  float dif = 0.75 + 0.35 * dot(n, L); float sp = pow(max(0.0, dot(reflect(-L, n), vec3(0, 0, 1))), 18.0) * p_gloss / 100.0;
  vec3 c = unpre(s); c = mix(vec3(luma(c)), c, 1.2) * dif + sp; o = pre(clamp(c, 0.0, 1.0), s.a);
}
