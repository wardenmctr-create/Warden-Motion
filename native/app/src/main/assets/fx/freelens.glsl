// freelens
uniform vec2 p_mercekKaym, p_egim; uniform float p_odakUzak, p_odakBandGeni, p_odakDisiBula;
void main() { vec2 q = toUnit(here()) - p_mercekKaym * 0.2; vec2 b = boxUV(here()) - 0.5; float plane = dot(b, vec2(sin(radians(p_egim.x)), sin(radians(p_egim.y)))) * 2.0 + (p_odakUzak - 50.0) / 50.0;
  float blur = smoothstep(p_odakBandGeni / 100.0 * 0.5, p_odakBandGeni / 100.0 * 0.5 + 0.3, abs(plane + b.y * 0.0)) * p_odakDisiBula * 0.15 * u_s; vec4 acc = vec4(0.0);
  for (int i = 0; i < 24; i++) { float a = float(i) * 2.39996; float r = blur * sqrt((float(i) + 0.5) / 24.0); acc += texU(q + vec2(cos(a), sin(a)) * r / u_s); } o = acc / 24.0; }
