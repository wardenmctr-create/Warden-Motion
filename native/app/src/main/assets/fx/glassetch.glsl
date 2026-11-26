// glassetch
uniform sampler2D s_oymaMask, s_arkaPlan; uniform float p_oymaMaskOn, p_arkaPlanOn, p_matlik, p_kirilma, p_kenarParl;
// Oyma bölgeleri (maske ya da desen) buzlu: arka plan bulanık ve beyazımsı; kenarda parlama; şeffaf bölgede hafif kırılma
vec4 bgAt(vec2 b) { return p_arkaPlanOn > 0.5 ? texture(s_arkaPlan, b) : texPx(boxPx(b)); }
float etch(vec2 b) { if (p_oymaMaskOn > 0.5) return texture(s_oymaMask, b).a; vec2 q = (b - 0.5) * 6.0; return step(0.5, fract(length(q) * 0.5 + atan(q.y, q.x) / 6.28318 * 2.0)); }
void main() { vec2 b = boxUV(here()); float m = etch(b); vec2 off = vec2(fbm(b * 9.0, 2.0), fbm(b * 9.0 + 4.0, 2.0)) * p_kirilma / max(u_box.z, 1.0) * u_s;
  vec4 clear = bgAt(b + off * 0.4); vec4 fr = vec4(0.0); float R = p_matlik / 100.0 * 10.0 / max(u_box.z, 1.0) * u_s; for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) fr += bgAt(b + off + vec2(i, j) * R); fr /= 25.0;
  fr.rgb = mix(fr.rgb, vec3(fr.a), 0.35 * p_matlik / 100.0); float e = abs(etch(b + vec2(1.5 / u_box.z, 0.0)) - etch(b - vec2(1.5 / u_box.z, 0.0))) + abs(etch(b + vec2(0.0, 1.5 / u_box.w)) - etch(b - vec2(0.0, 1.5 / u_box.w)));
  vec4 r = mix(clear, fr, m); r.rgb += vec3(1.0) * clamp(e, 0.0, 1.0) * p_kenarParl / 100.0 * r.a; o = r; }
