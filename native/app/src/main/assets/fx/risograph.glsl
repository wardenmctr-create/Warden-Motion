// risograph
uniform float p_plakaSayi, p_tram; uniform vec2 p_plakaKaym; uniform vec3 c_plakaRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec3 inks[4] = vec3[4](c_plakaRenk, vec3(0.13, 0.42, 0.85), vec3(1.0, 0.85, 0.1), vec3(0.1, 0.1, 0.12)); int N = int(clamp(p_plakaSayi, 1.0, 4.0)); vec3 res = vec3(1.0);
  for (int k = 0; k < 4; k++) { if (k >= N) break; vec2 off = p_plakaKaym * float(k) * u_s * 0.5; vec3 c = unpre(texPx(here() - off)); float a = texPx(here() - off).a;
    float amt = k == 0 ? (1.0 - luma(c)) * 0.6 + c.r * 0.4 : k == 1 ? (1.0 - c.r) * 0.8 : k == 2 ? (1.0 - c.b) * c.g : (1.0 - luma(c)) * 0.5; amt *= a;
    vec2 g = rot2(15.0 + float(k) * 30.0) * toUnit(here()) / max(p_tram, 1.0); float dot_ = 1.0 - smoothstep(sqrt(amt) * 0.55 - 0.08, sqrt(amt) * 0.55 + 0.08, length(fract(g) - 0.5));
    res *= mix(vec3(1.0), inks[k], dot_ * (0.85 + 0.15 * vnoise(toUnit(here()) * 0.8 + float(k) * 9.0))); }
  vec3 paper = vec3(0.97, 0.95, 0.9); o = pre(res * paper, s.a); }
