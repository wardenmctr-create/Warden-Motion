// anaglyph
uniform sampler2D s_solGozKatm, s_sagGozKatm; uniform float p_solGozKatmOn, p_sagGozKatmOn;
uniform float p_ayrisma, p_yakinsam, p_filtre, p_gozleriDegi;
void main() {
  float d = (p_ayrisma - p_yakinsam) * u_s * 0.5; if (p_gozleriDegi > 0.5) d = -d;
  vec4 L = p_solGozKatmOn > 0.5 ? texture(s_solGozKatm, clamp(boxUV(here()), 0.0, 1.0)) : texPx(here() + vec2(d, 0.0));
  vec4 R = p_sagGozKatmOn > 0.5 ? texture(s_sagGozKatm, clamp(boxUV(here()), 0.0, 1.0)) : texPx(here() - vec2(d, 0.0));
  vec3 l = unpre(L), r = unpre(R);
  vec3 c = p_filtre < 0.5 ? vec3(luma(l) * 0.3 + l.r * 0.7, r.g, r.b) : vec3(r.r, luma(l) * 0.3 + l.g * 0.7, r.b);
  float a = max(L.a, R.a);
  o = pre(c, a);
}
