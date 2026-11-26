// inkwash
uniform float p_yayilma, p_kenarPigm, p_kuruma;
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_yayilma, 0.5) * u_s; vec4 acc = vec4(0.0); for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float r = R * sqrt((float(i) + 0.5) / 16.0); vec2 w = vec2(pnoise(toUnit(here()) * 0.05 + float(i)), pnoise(toUnit(here()) * 0.05 + 7.0)) * R * 0.3; acc += texPx(here() + vec2(cos(a), sin(a)) * r + w); } acc /= 16.0;
  float e = clamp(length(alphaGrad(here(), R * 0.5)) * 3.0 + sobel(here(), R * 0.3) * 2.0, 0.0, 1.0); vec3 c = acc.a > 0.0 ? acc.rgb / acc.a : vec3(1.0); c = mix(vec3(1.0), c, 0.6 + 0.4 * (1.0 - p_kuruma / 200.0)); c *= 1.0 - e * p_kenarPigm / 100.0 * 0.6;
  o = pre(clamp(c, 0.0, 1.0), max(s.a, acc.a * (1.0 - p_kuruma / 100.0 * 0.5))); }
