// tiltshift
uniform sampler2D u_aux; uniform float p_focus; uniform float p_width; uniform float p_sat;
void main() { vec4 s = texture(u_tex, v_uv), b = texture(u_aux, v_uv); float y = boxUV(v_uv * u_res).y - 0.5 - p_focus / 200.0; float w = p_width / 200.0;
  float k = smoothstep(w, w + 0.25, abs(y)); vec4 r = mix(s, b, k); if (p_sat > 0.5 && r.a > 0.0) { vec3 c = unpre(r); c = mix(vec3(luma(c)), c, 1.35); c = (c - 0.5) * 1.1 + 0.5; r = pre(clamp(c, 0.0, 1.0), r.a); } o = r; }
