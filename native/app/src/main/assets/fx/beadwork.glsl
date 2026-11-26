// beadwork
uniform float p_boncukCapi, p_aralik, p_isikGucu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float P = max(p_boncukCapi + p_aralik, 1.0); vec2 id = floor(q / P); vec2 f = (fract(q / P) - 0.5) * P; float R = p_boncukCapi * 0.5;
  vec4 src = texU((id + 0.5) * P); float d = length(f); if (d > R || src.a < 0.3) { o = vec4(0.0); return; } vec3 n = vec3(f / R, sqrt(max(0.0, 1.0 - dot(f, f) / (R * R))));
  vec3 c = unpre(src); float lit = 0.6 + 0.5 * max(dot(n, normalize(vec3(-0.5, -0.6, 0.7))), 0.0); float sp = pow(max(dot(n, normalize(vec3(-0.3, -0.4, 1.0))), 0.0), 40.0) * p_isikGucu / 100.0; o = pre(clamp(c * lit + sp, 0.0, 1.0), src.a); }
