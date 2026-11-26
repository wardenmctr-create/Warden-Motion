// Ortak "Karışım": efektli sonuç (u_tex) ile efektten önceki hâl (u_src)
uniform sampler2D u_src; uniform float u_mix;
void main() { o = mix(texture(u_src, v_uv), texture(u_tex, v_uv), clamp(u_mix, 0.0, 1.0)); }
