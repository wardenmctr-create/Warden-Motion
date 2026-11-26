// brushstrokes
uniform float p_fircaBoyu, p_darbeUzun, p_aci, p_aciCesi, p_yogunluk, p_tohum, p_kaynakRenkKoru;
void main() {
  vec4 s0 = texture(u_tex, v_uv); vec2 px = here(); float sz = max(p_fircaBoyu * u_s, 2.0); vec2 id = floor(px / sz);
  vec4 acc = vec4(0.0); float ws = 0.0;
  for (int i = -1; i <= 1; i++) for (int j = -1; j <= 1; j++) {
    vec2 cid = id + vec2(float(i), float(j)); vec2 r = hash2(cid + seedf(p_tohum)); vec2 cp = (cid + r) * sz;
    float a = radians(p_aci + (r.x - 0.5) * 2.0 * p_aciCesi * 0.9); vec2 dir = vec2(cos(a), sin(a));
    vec2 rel = px - cp; float u = dot(rel, dir), v = dot(rel, vec2(-dir.y, dir.x)); float L = max(p_darbeUzun * u_s * 0.5, sz * 0.5);
    float m = (1.0 - smoothstep(L * 0.7, L, abs(u))) * (1.0 - smoothstep(sz * 0.35, sz * 0.55, abs(v)));
    vec4 c = texPx(cp); acc += c * m; ws += m;
  }
  vec4 b = ws > 0.0 ? acc / ws : s0;
  b.rgb *= 1.0 + (hash1(floor(px / 2.0)) - 0.5) * 0.06;
  o = mix(s0, b, p_yogunluk / 100.0) * (s0.a > 0.0 || p_kaynakRenkKoru < 0.5 ? 1.0 : 0.0);
}
