// truchet
uniform float p_karoBoyu, p_yolBici, p_cizgiKali, p_tohum, p_yonDagi, p_donus; uniform vec2 p_kayma; uniform vec3 c_cizgiReng, c_zeminReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_donus) * toUnit(here()) + p_kayma; float T = max(p_karoBoyu, 4.0); vec2 id = floor(q / T); vec2 f = fract(q / T) - 0.5;
  float h = hash1(id + seedf(p_tohum)); if (h < p_yonDagi / 100.0) f.x = -f.x; float kind = p_yolBici < 1.5 ? p_yolBici : step(0.5, hash1(id + 9.0)); float d;
  if (kind < 0.5) { vec2 c = f.x + f.y > 0.0 ? vec2(0.5) : vec2(-0.5); d = abs(length(f - c) - 0.5); } else d = min(abs(f.x + f.y) , abs(f.x - f.y + (f.x - f.y > 0.0 ? -1.0 : 1.0) * 0.0) * 9.0) ;
  if (kind > 0.5) d = abs(f.x + f.y) / 1.4142; float line = 1.0 - smoothstep(p_cizgiKali / T * 0.5, p_cizgiKali / T * 0.5 + 1.0 / (T * u_s), d);
  vec3 c = mix(c_zeminReng, c_cizgiReng, line); o = overPre(pre(c, 1.0) * s.a, vec4(0.0)) ; }
