// behindobject
uniform sampler2D s_onPlanMask, s_hedefKlip; uniform float p_onPlanMaskOn, p_hedefKlipOn, p_ilerleme, p_kenarPayi;
// Silme geçişi ön plan nesnesinin arkasından geçer: hedef klip soldan açılır, maske bölgesi (genişletilmiş) üstte kalır
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec4 t = p_hedefKlipOn > 0.5 ? texture(s_hedefKlip, b) : vec4(hueRotate(unpre(s), 180.0) * s.a, s.a); float e = p_ilerleme / 100.0 * 1.2 - 0.1;
  float wipe = smoothstep(e + 0.02, e - 0.02, b.x); float m = 0.0; if (p_onPlanMaskOn > 0.5) { float r = p_kenarPayi / max(u_box.z, 1.0) * u_s; for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) m = max(m, texture(s_onPlanMask, b + vec2(i, j) * r).a); }
  vec4 bg = mix(s, t, wipe); o = mix(bg, s, m); }
