// highlightrecover
uniform float p_kirpilmaEsig, p_karisim, p_renkGeci;
void main() { vec4 s = texture(u_tex, v_uv); vec3 c = unpre(s); float th = p_kirpilmaEsig / 100.0; float mx = max(c.r, max(c.g, c.b)); if (mx < th) { o = s; return; }
  vec3 acc = vec3(0.0); float ws = 0.0; for (int i = 0; i < 16; i++) { float a = float(i) * 2.39996; float r = (4.0 + float(i) * 2.0) * u_s; vec3 n = unpre(texPx(here() + vec2(cos(a), sin(a)) * r)); float w = 1.0 - smoothstep(th - 0.1, th, max(n.r, max(n.g, n.b))); acc += n * w; ws += w; }
  vec3 hue = ws > 0.0 ? acc / ws : c; vec3 rec = c; if (p_renkGeci > 0.5 && ws > 0.0) rec = hue / max(max(hue.r, max(hue.g, hue.b)), 1e-3) * mx * 0.97; else rec = c * (th + (1.0 - th) * 0.5) / max(mx, 1e-3);
  float k = smoothstep(th, 1.0, mx) * p_karisim / 100.0; o = pre(clamp(mix(c, rec, k), 0.0, 1.0), s.a); }
