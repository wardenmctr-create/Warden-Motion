// multicam
uniform sampler2D s_kamerala; uniform float p_kameralaOn, p_duzen, p_seciliKame;
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 cam = p_kameralaOn > 0.5 ? texture(s_kamerala, b) : vec4(vec3(1.0) - s.rgb, s.a);
  if (p_duzen < 0.5) { vec2 g = floor(b * 2.0); vec2 f = fract(b * 2.0); vec4 c = (g.x + g.y * 2.0) < 0.5 ? texPx(boxPx(f)) : (p_kameralaOn > 0.5 ? texture(s_kamerala, f) : vec4(texPx(boxPx(f)).rgb * vec3(0.6, 0.8, 1.0), 1.0)); float sel = (g.x + g.y * 2.0 + 1.0) == floor(p_seciliKame) ? 1.0 : 0.0; float edge = step(min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)), 0.015); o = overPre(vec4(1.0, 0.75, 0.2, 1.0) * edge * sel, c); }
  else if (p_duzen < 1.5) { vec2 f = vec2(fract(b.x * 2.0), b.y); o = b.x < 0.5 ? texPx(boxPx(f)) : (p_kameralaOn > 0.5 ? texture(s_kamerala, f) : texPx(boxPx(f)) * 0.7); }
  else { vec4 c = texPx(boxPx(b)); vec2 pip = (b - vec2(0.68, 0.68)) / 0.28; if (all(greaterThanEqual(pip, vec2(0.0))) && all(lessThanEqual(pip, vec2(1.0)))) c = p_kameralaOn > 0.5 ? texture(s_kamerala, pip) : texPx(boxPx(pip)) * 0.7; o = c; } }
