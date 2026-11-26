// meteors
uniform float p_meteorYogu, p_buyukluk, p_rastgeleBuyu, p_hiz, p_yon, p_yonDagi, p_yasamSure, p_izUzun, p_parlama, p_tohum, p_dongu; uniform vec3 c_meteorReng, c_kuyrukReng;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 B = boxU(); vec4 acc = vec4(0.0); float N = clamp(p_meteorYogu, 0.0, 60.0); float life = max(p_yasamSure, 0.1);
  for (int i = 0; i < 60; i++) { if (float(i) >= N) break; float fi = float(i); float per = life * 1.6; float ph = u_t / per + hash1(vec2(fi, seedf(p_tohum))); float cyc = floor(ph); float k = fract(ph) * 1.6;
    if (p_dongu < 0.5 && u_dur > 0.0 && cyc * per > u_dur) continue; if (k > 1.0) continue;
    vec2 h = hash2(vec2(fi + cyc * 13.7, seedf(p_tohum) + 3.0)); float ang = radians(p_yon + (hash1(vec2(fi, cyc + 9.0)) - 0.5) * 2.0 * p_yonDagi); vec2 dir = vec2(cos(ang), sin(ang));
    vec2 st = (h - 0.5) * B * 1.4 - dir * B * 0.35; vec2 head = st + dir * p_hiz * k * life; float sz = p_buyukluk * (1.0 + (hash1(vec2(fi, cyc + 2.0)) - 0.5) * p_rastgeleBuyu / 50.0);
    vec2 d = q - head; float along = dot(d, -dir); float perp = abs(dot(d, vec2(-dir.y, dir.x))); float fade = sin(k * PI);
    float tail = step(0.0, along) * (1.0 - smoothstep(0.0, max(p_izUzun, 1.0), along)) * (1.0 - smoothstep(sz * 0.2, sz * 0.6 * (1.0 - along / max(p_izUzun, 1.0)) + 0.3, perp));
    float hd = 1.0 - smoothstep(sz * 0.3, sz, length(d)); float gl = exp(-length(d) / max(sz * 3.0, 1.0)) * p_parlama / 100.0 * 0.6;
    acc = overPre(vec4(c_kuyrukReng, 1.0) * tail * fade * 0.85, acc); acc = overPre(vec4(c_meteorReng, 1.0) * clamp(hd + gl, 0.0, 1.0) * fade, acc); }
  o = overPre(acc, s); }
