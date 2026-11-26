// blobby_c
uniform sampler2D u_src; uniform sampler2D u_aux; uniform float p_damlalas, p_yumusatm, p_esik, p_yuzeyParl, p_isikAcis, p_yalnizAlfa;
void main() {
  vec4 b = texture(u_aux, v_uv); float th = p_esik / 100.0; float sw = 0.02 + p_yumusatm / 200.0;
  float a = smoothstep(th - sw, th + sw, b.a);
  vec2 e = 1.5 / u_res;
  float gx = texture(u_aux, v_uv + vec2(e.x, 0.0)).a - texture(u_aux, v_uv - vec2(e.x, 0.0)).a;
  float gy = texture(u_aux, v_uv + vec2(0.0, e.y)).a - texture(u_aux, v_uv - vec2(0.0, e.y)).a;
  vec3 nrm = normalize(vec3(-gx * 6.0, -gy * 6.0, 1.0)); float la = radians(p_isikAcis);
  vec3 L = normalize(vec3(cos(la), sin(la), 1.2)); float sp = pow(max(dot(reflect(-L, nrm), vec3(0, 0, 1)), 0.0), 18.0) * p_yuzeyParl / 100.0;
  vec3 col = p_yalnizAlfa > 0.5 ? unpre(texture(u_src, v_uv)) : (b.a > 0.001 ? b.rgb / b.a : vec3(0.0));
  if (p_yalnizAlfa > 0.5 && texture(u_src, v_uv).a < 0.01) col = b.a > 0.001 ? b.rgb / b.a : vec3(0.0);
  o = pre(clamp(col * (0.85 + 0.15 * dot(nrm, L)) + sp, 0.0, 1.0), a);
}
