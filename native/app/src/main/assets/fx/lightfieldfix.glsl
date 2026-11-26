// lightfieldfix
uniform sampler2D s_referans; uniform float p_referansOn, p_alanOlce, p_zamansalYumu, p_guc;
// Geniş ölçekli ışık alanı: kendi ve referansın büyük pencere ortalama parlaklığı oranı ile kazanç
float wide(vec2 px, bool ref) { float R = p_alanOlce * u_s; float a = 0.0, w = 0.0; for (int j = -3; j <= 3; j++) for (int i = -3; i <= 3; i++) { vec2 q = px + vec2(i, j) / 3.0 * R; vec4 c = ref ? texture(s_referans, boxUV(q)) : texPx(q); if (c.a <= 0.0) continue; a += luma(unpre(c)); w += 1.0; } return w > 0.0 ? a / w : 0.5; }
void main() { vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; } float me = max(wide(here(), false), 0.02); float target = p_referansOn > 0.5 ? wide(here(), true) : 0.5;
  float g = clamp(target / me, 0.25, 4.0); vec3 c = unpre(s); o = pre(clamp(mix(c, c * g, p_guc / 100.0), 0.0, 1.0), s.a); }
