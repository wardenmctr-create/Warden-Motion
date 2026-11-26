// alphadist
uniform float p_azamiMesa, p_isaretliMesa, p_gorunum;
void main() { vec4 s = texture(u_tex, v_uv); float R = max(p_azamiMesa, 1.0) * u_s; float inside = step(0.5, s.a); float d = inside > 0.5 ? innerDist(here(), R) : outerDist(here(), R); float v = d / R;
  if (p_isaretliMesa > 0.5) v = inside > 0.5 ? 0.5 + v * 0.5 : 0.5 - v * 0.5; else if (inside < 0.5) v = 0.0;
  if (p_gorunum < 0.5) o = vec4(vec3(v), 1.0); else if (p_gorunum < 1.5) o = vec4(hsv2rgb(vec3(0.7 - v * 0.7, 0.9, 1.0)), 1.0); else o = vec4(vec3(v), v); }
