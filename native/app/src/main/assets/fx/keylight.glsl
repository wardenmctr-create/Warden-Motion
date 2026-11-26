// keylight
uniform vec3 c_perdeReng; uniform float p_perdeKaza, p_perdeDeng, p_siyahKirp, p_beyazKirp, p_kenarDara, p_yumusatm, p_tasmaTemi, p_gorunum;
float km(vec2 px) { vec4 s = texPx(px); vec3 c = unpre(s); vec3 k = c_perdeReng; int ch = k.g >= k.r && k.g >= k.b ? 1 : (k.b >= k.r ? 2 : 0);
  float kc = ch == 1 ? c.g : ch == 2 ? c.b : c.r; float o1 = ch == 1 ? c.r : c.g, o2 = ch == 2 ? c.r : (ch == 1 ? c.b : c.b); float bal = p_perdeDeng / 100.0;
  float diff = kc - (o1 * bal + o2 * (1.0 - bal)); float a = 1.0 - clamp(diff * p_perdeKaza / 100.0 * 3.0, 0.0, 1.0);
  a = clamp((a - p_siyahKirp / 100.0) / max(p_beyazKirp / 100.0 - p_siyahKirp / 100.0, 0.01), 0.0, 1.0); return a * s.a; }
void main() { vec4 s = texture(u_tex, v_uv); float a = km(here());
  if (p_yumusatm > 0.3 || abs(p_kenarDara) > 0.1) { float r = max(p_yumusatm, abs(p_kenarDara)) * u_s; float acc = a, mn = a, mx = a; for (int i = 0; i < 8; i++) { float an = float(i) * TAU / 8.0; float x = km(here() + vec2(cos(an), sin(an)) * r); acc += x; mn = min(mn, x); mx = max(mx, x); }
    a = p_kenarDara < -0.1 ? mn : p_kenarDara > 0.1 ? mx : acc / 9.0; }
  if (p_gorunum > 0.5 && p_gorunum < 1.5) { o = vec4(vec3(a), 1.0); return; }
  vec3 c = unpre(s); vec3 k = c_perdeReng; int ch = k.g >= k.r && k.g >= k.b ? 1 : (k.b >= k.r ? 2 : 0); float lim = ch == 1 ? (c.r + c.b) * 0.5 : ch == 2 ? (c.r + c.g) * 0.5 : (c.g + c.b) * 0.5;
  float t = p_tasmaTemi / 100.0; if (ch == 1) c.g = mix(c.g, min(c.g, lim), t); else if (ch == 2) c.b = mix(c.b, min(c.b, lim), t); else c.r = mix(c.r, min(c.r, lim), t);
  if (p_gorunum > 1.5) { o = vec4(mix(vec3(0.0, 0.0, 0.0), vec3(1.0), a) * vec3(1.0, a > 0.98 ? 1.0 : 0.5, a < 0.02 ? 1.0 : 0.5), 1.0); return; }
  o = pre(c, a); }
