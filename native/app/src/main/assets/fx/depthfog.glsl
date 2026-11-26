// depthfog
uniform sampler2D u_depth; uniform vec3 c_sisReng; uniform float p_baslangi, p_bitis, p_yogunluk, p_dagilim, p_derinligTersCevi;
void main() { vec4 s = texture(u_tex, v_uv); float d = luma(unpre(texture(u_depth, v_uv))); if (p_derinligTersCevi < 0.5) d = 1.0 - d;
  float k = clamp((d - p_baslangi / 100.0) / max((p_bitis - p_baslangi) / 100.0, 0.01), 0.0, 1.0); if (p_dagilim > 0.5) k = 1.0 - exp(-k * 3.0); k *= p_yogunluk / 100.0; o = pre(mix(unpre(s), c_sisReng, k), s.a); }
