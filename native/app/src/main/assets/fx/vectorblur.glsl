// vectorblur
uniform float p_amount; uniform float p_ang;
vec2 grad(vec2 uv) { vec2 d = 1.5 / u_res; return vec2(luma(tex(uv + vec2(d.x, 0)).rgb) - luma(tex(uv - vec2(d.x, 0)).rgb), luma(tex(uv + vec2(0, d.y)).rgb) - luma(tex(uv - vec2(0, d.y)).rgb)); }
void main() { vec2 uv = v_uv; vec4 acc = texture(u_tex, uv); float n = 1.0; float stp = p_amount * u_s / 16.0;
  for (int k = 0; k < 2; k++) { vec2 q = uv; float sg = k == 0 ? 1.0 : -1.0; for (int i = 0; i < 8; i++) { vec2 g = grad(q); vec2 dir = length(g) > 1e-4 ? normalize(rot2(p_ang) * g) : vec2(1, 0); q += dir * stp * sg / u_res; acc += tex(q); n += 1.0; } }
  o = acc / n; }
