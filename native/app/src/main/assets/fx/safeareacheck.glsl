// safeareacheck
uniform sampler2D s_onemliBolg; uniform float p_onemliBolgOn, p_oranlar, p_guvenPayi, p_ihlalUyar;
// 9:16, 1:1 ve 4:5 kırpma kılavuzları (güven payıyla); önemli bölge (kaynak alfa) bir kılavuzun dışına taşıyorsa kırmızı
float frameFor(vec2 b, float ar, float pad) { float W = u_box.z, H = u_box.w; vec2 sz = W / H > ar ? vec2(ar * H / W, 1.0) : vec2(1.0, W / (ar * H)); sz *= 1.0 - pad * 2.0; vec2 d = abs(b - 0.5) - sz * 0.5; return max(d.x, d.y); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float pad = p_guvenPayi / 100.0; vec4 res = s; float imp = p_onemliBolgOn > 0.5 ? texture(s_onemliBolg, b).a : 0.0; float viol = 0.0;
  for (int i = 0; i < 3; i++) { float ar = i == 0 ? 9.0 / 16.0 : (i == 1 ? 1.0 : 0.8); float d = frameFor(b, ar, pad); vec3 c = i == 0 ? vec3(0.3, 0.8, 1.0) : (i == 1 ? vec3(1.0, 0.85, 0.3) : vec3(0.6, 1.0, 0.5));
    res = overPre(vec4(c, 1.0) * (1.0 - smoothstep(0.0, 1.5 / u_box.z, abs(d))), res); if (d > 0.0 && imp > 0.5) viol = 1.0; }
  if (p_ihlalUyar > 0.5) res = mix(res, vec4(1.0, 0.2, 0.2, 1.0), viol * 0.55); o = res; }
