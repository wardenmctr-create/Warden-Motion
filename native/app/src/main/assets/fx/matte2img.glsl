// matte2img
uniform float p_tersCevi, p_rgbVeyaAlfa; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); float a = p_tersCevi > 0.5 ? 1.0 - s.a : s.a; o = p_rgbVeyaAlfa < 0.5 ? vec4(c_renk * a, 1.0) : vec4(c_renk * a, a); }
