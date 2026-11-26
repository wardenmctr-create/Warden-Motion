// coin3d
INCLUDE(_3d)
uniform sampler2D s_onYuz, s_arkaYuz; uniform float p_onYuzOn, p_arkaYuzOn;
uniform float p_cap, p_kalinlik, p_pah, p_bicim, p_kenarSayi, p_tirtikliKena, p_tirtikSayi, p_tirtikDeri, p_yuzeyKaba, p_otomatikDonm, p_donmeHizi, p_yalpalam;
float sdf(vec3 p) { float R = max(p_cap * 0.5, 2.0); float a = atan(p.y, p.x); float r = length(p.xy);
  float d2 = p_bicim < 0.5 || p_bicim > 1.5 ? r - R : (cos(PI / max(floor(p_kenarSayi), 3.0)) / cos(mod(a, TAU / max(floor(p_kenarSayi), 3.0)) - PI / max(floor(p_kenarSayi), 3.0))) * r - R;
  if (p_tirtikliKena > 0.5) d2 += p_tirtikDeri * 0.5 * (0.5 + 0.5 * cos(a * max(p_tirtikSayi, 8.0))) * smoothstep(-2.0, 0.0, d2);
  float h = max(p_kalinlik, 0.5) * 0.5; vec2 w = vec2(d2 + p_pah * 0.5, abs(p.z) - h); return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - p_pah * 0.5; }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p.xy / max(p_cap, 1.0) + 0.5; uv.y = 1.0 - uv.y; vec3 c = c_tabanRenk;
  if (abs(n.z) > 0.5) { bool front = n.z > 0.0; vec4 t = front ? (p_onYuzOn > 0.5 ? texture(s_onYuz, clamp(uv, 0.0, 1.0)) : layerAt(uv)) : (p_arkaYuzOn > 0.5 ? texture(s_arkaYuz, clamp(vec2(1.0 - uv.x, uv.y), 0.0, 1.0)) : layerAt(vec2(1.0 - uv.x, uv.y)));
    float l = luma(t.a > 0.0 ? t.rgb / t.a : vec3(0.0)); c = mix(c_tabanRenk * (0.7 + 0.5 * l), t.a > 0.0 ? t.rgb / t.a : c_tabanRenk, p_malzeme > 0.5 && p_malzeme < 1.5 ? 0.25 : 0.85);
    c *= 1.0 + (vnoise(p.xy * 0.6) - 0.5) * p_yuzeyKaba / 100.0 * 0.3; } else c *= 0.85;
  return vec4(c, 1.0); }
void main() { vec3 ex = vec3(0.0); if (p_otomatikDonm > 0.5) ex = vec3(sin(u_t * 3.0) * p_yalpalam, u_t * p_donmeHizi, 0.0); o = render3d(ex); }
