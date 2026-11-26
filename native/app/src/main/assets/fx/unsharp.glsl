// unsharp
uniform float p_miktar, p_yaricap, p_esik, p_yalnizParl;
void main() {
  vec4 s = texture(u_tex, v_uv); float sg = max(p_yaricap * u_s * 0.5, 0.5); vec4 b = vec4(0.0); float ws = 0.0;
  for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 f = vec2(float(i), float(j)); float w = exp(-dot(f, f) / 4.5); b += texPx(here() + f * sg * 0.7) * w; ws += w; } b /= ws;
  vec3 c = unpre(s), bc = unpre(b); vec3 d = c - bc; float m = step(p_esik / 100.0 * 0.3, abs(luma(c) - luma(bc)));
  vec3 r = p_yalnizParl > 0.5 ? c + (luma(c) - luma(bc)) * p_miktar / 100.0 * m : c + d * p_miktar / 100.0 * m;
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
