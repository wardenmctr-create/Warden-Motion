// shadowtheater
uniform vec2 p_isik; uniform float p_perdeUzak, p_golgeYumu; uniform vec3 c_perdeReng, c_golgeReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float k = 1.0 + p_perdeUzak / 400.0; vec2 sq = (q - p_isik) / k + p_isik; float a = 0.0; float R = p_golgeYumu * u_s * (0.3 + p_perdeUzak / 500.0);
  for (int i = 0; i < 12; i++) { float an = float(i) * 0.5236; a += texU(sq + vec2(cos(an), sin(an)) * R / u_s * fract(float(i) * 0.618 + 0.3)).a; } a /= 12.0;
  float glow = 1.0 - length(boxUV(here()) - 0.5) * 0.9; vec3 c = mix(c_perdeReng * (0.7 + 0.4 * glow), c_golgeReng, a); o = vec4(c, 1.0); }
