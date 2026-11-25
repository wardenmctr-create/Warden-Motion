// compoundblur
uniform sampler2D u_aux; uniform float p_map;
void main() { vec4 s = texture(u_tex, v_uv), b = texture(u_aux, v_uv); vec2 q = boxUV(v_uv * u_res) - 0.5; int m = int(p_map + 0.5); float k;
  if (m == 0) k = smoothstep(0.15, 0.6, length(q) * 1.3); else if (m == 1) k = 1.0 - smoothstep(0.0, 0.45, length(q)); else if (m == 2) k = luma(unpre(s)); else if (m == 3) k = 1.0 - luma(unpre(s)); else k = clamp(q.y + 0.5, 0.0, 1.0);
  o = mix(s, b, k); }
