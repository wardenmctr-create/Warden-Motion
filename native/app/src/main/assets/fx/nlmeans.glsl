// nlmeans
uniform float p_yamaBoyu, p_aramaBoyu, p_guc;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c0 = unpre(s); float h = p_guc / 100.0 * 0.25 + 0.005; float S = floor(p_aramaBoyu * 0.5); float P = floor(p_yamaBoyu * 0.5); vec3 acc = vec3(0.0); float ws = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 o2 = vec2(i, j) * S / 3.0 * u_s; float d = 0.0;
    for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) { vec2 pp = vec2(x, y) * P * u_s; vec3 a = unpre(texPx(here() + pp)), b = unpre(texPx(here() + o2 + pp)); vec3 e = a - b; d += dot(e, e); }
    float w = exp(-d / 9.0 / (h * h)); acc += unpre(texPx(here() + o2)) * w; ws += w; }
  o = pre(acc / ws, s.a); }
