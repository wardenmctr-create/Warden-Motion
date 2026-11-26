// tuningmeter
INCLUDE(_chart)
uniform float p_dvN, p_referansA, p_yumusatm, p_olcek, p_notaEtik;
// Yarım daire gösterge: −50…+50 cent; ibre sapmayı, renk doğruluğu gösterir; altta nota numarası ya da Hz
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - vec2(0.0, boxU().y * 0.15); float R = min(boxU().x, boxU().y) * 0.42; float cents = p_dvN > 0.5 ? dvAt(0) : sin(u_t * 1.3) * 30.0;
  float r = length(q); float ang = atan(q.x, -q.y); vec4 res = s; if (q.y < 0.0 && r < R && r > R * 0.78) { float k = ang / 1.5708 * 50.0; vec3 c = mix(vec3(0.3, 0.9, 0.4), vec3(1.0, 0.35, 0.3), smoothstep(5.0, 40.0, abs(k))); res = overPre(vec4(c, 0.85), res);
    float tick = 1.0 - smoothstep(0.0, 0.015, abs(fract(k / 10.0 + 0.5) - 0.5)); res = overPre(vec4(vec3(1.0), 1.0) * tick, res); }
  float na = clamp(cents, -50.0, 50.0) / 50.0 * 1.5708; vec2 dir = vec2(sin(na), -cos(na)); float tt = clamp(dot(q, dir), 0.0, R * 0.95); float nd = length(q - dir * tt); res = overPre(vec4(1.0) * (1.0 - smoothstep(1.0, 2.2, nd * u_s)) * step(0.0, -q.y + 1.0), res);
  vec2 lp = (q - vec2(0.0, R * 0.25)) / (R * 0.12); float val = p_olcek < 0.5 ? (p_notaEtik > 0.5 ? (p_dvN > 0.5 ? dvAt(1) : 69.0) : abs(cents)) : (p_dvN > 0.5 ? dvAt(2) : p_referansA); res = overPre(vec4(1.0) * numAt(lp, val), res); o = res; }
