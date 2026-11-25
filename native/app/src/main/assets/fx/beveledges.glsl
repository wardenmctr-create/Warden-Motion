// beveledges
uniform float p_width; uniform float p_ang; uniform float p_light;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  vec2 b = boxUV(v_uv * u_res); vec2 wpx = vec2(p_width * u_s) / u_box.zw; vec2 L = vec2(cos(radians(p_ang)), sin(radians(p_ang)));
  vec2 n = vec2(0.0); if (b.x < wpx.x) n.x = -1.0; else if (b.x > 1.0 - wpx.x) n.x = 1.0; if (b.y < wpx.y) n.y = -1.0; else if (b.y > 1.0 - wpx.y) n.y = 1.0;
  float v = -dot(normalize(n + 1e-5) * step(0.1, length(n)), L) * p_light / 100.0;
  vec3 c = unpre(s); c = v > 0.0 ? mix(c, vec3(1.0), v * 0.7) : mix(c, vec3(0.0), -v * 0.6); o = pre(c, s.a);
}
