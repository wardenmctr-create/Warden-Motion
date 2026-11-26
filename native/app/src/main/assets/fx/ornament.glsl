// ornament
uniform float p_geometri, p_karoBoyu, p_icYari, p_aci, p_cizgiKali, p_dolguGost; uniform vec2 p_kayma; uniform vec3 c_anaRenk, c_ikinciRenk, c_cizgiReng;
float star(vec2 p, float n, float inner) { float a = atan(p.y, p.x); float sec = TAU / n; float la = abs(mod(a, sec) - sec * 0.5); vec2 q = vec2(cos(la), sin(la)) * length(p);
  vec2 A = vec2(1.0, 0.0), B = vec2(cos(sec * 0.5), sin(sec * 0.5)) * inner; vec2 e = B - A; vec2 w = q - A; float d = length(w - e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0)); return d * sign(e.x * w.y - e.y * w.x); }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()) + p_kayma; float T = max(p_karoBoyu, 8.0); float n = p_geometri < 0.5 ? 4.0 : p_geometri < 1.5 ? 6.0 : p_geometri < 2.5 ? 8.0 : 12.0;
  vec2 f; if (n == 6.0 || n == 12.0) { vec4 h = hexGrid(q / T, 1.0); f = h.xy; } else f = fract(q / T) - 0.5; vec2 p = f * 2.0;
  float d = star(p, n, p_icYari / 100.0 * 0.9 + 0.05); float d2 = star(rot2(180.0 / n) * p * 1.35, n, p_icYari / 100.0 * 0.9 + 0.05);
  float line = 1.0 - smoothstep(p_cizgiKali / T, p_cizgiKali / T + 1.5 / (T * u_s), min(abs(d), abs(d2)));
  vec3 c = p_dolguGost > 0.5 ? (d < 0.0 ? c_ikinciRenk : c_anaRenk) : c_anaRenk; c = mix(c, c_cizgiReng, line); o = pre(c, 1.0) * s.a; }
