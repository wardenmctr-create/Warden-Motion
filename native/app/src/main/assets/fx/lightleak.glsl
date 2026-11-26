// lightleak
uniform vec2 p_kaynak; uniform float p_yayilim, p_hareket, p_isikGucu; uniform vec3 c_isikRenk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 c = p_kaynak + vec2(sin(u_t * p_hareket / 30.0), cos(u_t * p_hareket / 40.0)) * boxU() * 0.1; float d = length(q - c) / max(p_yayilim / 100.0 * length(boxU()), 1.0);
  float g = exp(-d * d * 2.0) * (0.7 + 0.3 * fbm01(q * 0.005 + u_t * p_hareket / 200.0, 3.0)); vec3 add = c_isikRenk * g * p_isikGucu / 100.0; o = pre(clamp(screenB(unpre(s), add), 0.0, 1.0), s.a); }
