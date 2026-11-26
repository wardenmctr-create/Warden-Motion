// depthrim
uniform sampler2D s_derinlik; uniform vec3 c_renk; uniform float p_derinlikOn, p_derinlikEsig, p_hale, p_guc;
// Derinlik süreksizliği: komşulardan daha yakın (daha parlak) olan kenar piksellerinde, dışa doğru hale
float dep(vec2 px) { return p_derinlikOn > 0.5 ? luma(texture(s_derinlik, boxUV(px)).rgb) : lumAt(px); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); float H = max(p_hale * u_s, 1.0); float th = p_derinlikEsig / 100.0; float g = 0.0;
  for (int i = 0; i < 12; i++) { float a = float(i) / 12.0 * TAU; vec2 d = vec2(cos(a), sin(a)); for (int k = 1; k <= 4; k++) { float r = float(k) / 4.0 * H; float near = dep(p + d * r); float far = dep(p + d * (r + 2.0 * u_s));
      float jump = near - far; if (jump > th) { g = max(g, (1.0 - float(k - 1) / 4.0) * smoothstep(th, th + 0.1, jump)); } } }
  o = vec4(s.rgb + c_renk * g * p_guc / 100.0, max(s.a, g * p_guc / 100.0 * 0.8)); }
