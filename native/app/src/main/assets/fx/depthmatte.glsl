// depthmatte
uniform sampler2D u_depth; uniform float p_yakinSini, p_uzakSini, p_gecis, p_derinligTersCevi, p_matiGost;
void main() { vec4 s = texture(u_tex, v_uv); float d = luma(unpre(texture(u_depth, v_uv))); if (p_derinligTersCevi > 0.5) d = 1.0 - d; float w = p_gecis / 100.0 + 0.001;
  float m = smoothstep(p_yakinSini / 100.0 - w, p_yakinSini / 100.0, d) * (1.0 - smoothstep(p_uzakSini / 100.0, p_uzakSini / 100.0 + w, d)); if (p_matiGost > 0.5) { o = vec4(vec3(m), 1.0); return; } o = s * m; }
