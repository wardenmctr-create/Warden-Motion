// snowflake
uniform float p_yaricap, p_kolSayi, p_yanDalSayi, p_dalAcis, p_dalUzun, p_cizgiKali, p_buyume, p_tohum, p_parlama; uniform vec3 c_renk;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float N = max(floor(p_kolSayi), 3.0); float a = atan(q.y, q.x); float r = length(q); float sec = TAU / N;
  float la = mod(a + sec * 0.5, sec) - sec * 0.5; vec2 p = vec2(cos(la), abs(sin(la))) * r; float R = p_yaricap * p_buyume / 100.0; float w = p_cizgiKali * 0.5;
  float d = abs(p.y) + max(p.x - R, 0.0) + max(-p.x, 0.0); int B = int(clamp(p_yanDalSayi, 0.0, 12.0));
  for (int i = 0; i < 12; i++) { if (i >= B) break; float x0 = R * (float(i) + 1.0) / (float(B) + 1.0); float bl = R * p_dalUzun / 100.0 * (1.0 - float(i) / (float(B) + 1.0)) * (0.7 + 0.6 * hash1(vec2(float(i), seedf(p_tohum))));
    vec2 dir = vec2(cos(radians(p_dalAcis)), sin(radians(p_dalAcis))); vec2 rp = p - vec2(x0, 0.0); float t = clamp(dot(rp, dir), 0.0, bl * p_buyume / 100.0); d = min(d, length(rp - dir * t)); }
  float m = 1.0 - smoothstep(w, w + 0.8 / u_s, d); float glow = exp(-d / max(w * 4.0, 1.0)) * p_parlama / 100.0; o = overPre(vec4(c_renk, 1.0) * clamp(m + glow, 0.0, 1.0), s); }
