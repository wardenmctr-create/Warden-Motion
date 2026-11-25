// roughen
uniform float p_amount; uniform float p_scale; uniform float p_speed;
void main() {
  vec2 px = v_uv * u_res; float sc = p_scale * u_s; float t = u_t * p_speed;
  float n = fbm(px / sc + vec2(t * 0.3, t * 0.2), 4.0);
  vec2 d = vec2(fbm(px / sc + 5.2 + t * 0.2, 3.0), fbm(px / sc - 3.1 - t * 0.2, 3.0)) * p_amount * u_s;
  vec4 s = tex(v_uv + d / u_res); float a = s.a; float edge = smoothstep(0.35, 0.65, a + n * 0.35);
  o = a > 0.0 ? s * (edge / a) : vec4(0.0); o = vec4(unpre(s) * edge, edge);
}
