// cbsurprise
uniform vec2 p_merkez; uniform float p_bicim, p_boyut, p_kontur, p_donus, p_belirme, p_otomatikYayl; uniform vec3 c_renk, c_konturReng;
float shapeD(vec2 p) { // birim boyda işaret (y aşağı)
  if (p_bicim < 0.5) { float bar = max(abs(p.x) - 0.12, abs(p.y + 0.18) - 0.32); float dot_ = length(p - vec2(0.0, 0.38)) - 0.12; return min(bar, dot_); }
  if (p_bicim < 1.5) { float arc = abs(length(p - vec2(0.0, -0.2)) - 0.25) - 0.09; arc = max(arc, -(p.y + 0.2) - 0.0 + (p.x < 0.0 ? 1.0 : 0.0) * 0.0); float stem = max(abs(p.x) - 0.09, abs(p.y - 0.12) - 0.12); return min(min(arc, stem), length(p - vec2(0.0, 0.4)) - 0.1); }
  if (p_bicim < 2.5) { float d = 1e5; for (int i = -1; i <= 1; i++) { float a = radians(float(i) * 30.0 - 90.0); vec2 dir = vec2(cos(a), sin(a)); vec2 pp = p - dir * 0.15; float t = clamp(dot(pp, dir), 0.0, 0.35); d = min(d, length(pp - dir * t) - 0.07); } return d; }
  float a = atan(p.y, p.x); float r = length(p); float k = mix(0.2, 0.5, pow(abs(cos(a * 2.5)), 2.0)); return r - k; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); float pop = p_otomatikYayl > 0.5 ? 1.0 + 0.25 * exp(-u_t * 5.0) * sin(u_t * 25.0) : 1.0; float sc = max(p_boyut, 1.0) * p_belirme / 100.0 * pop;
  vec2 p = rot2(-p_donus) * (q - p_merkez) / max(sc, 0.01); float d = shapeD(p) * sc; float fill = 1.0 - smoothstep(-0.6, 0.6, d); float ring = 1.0 - smoothstep(p_kontur - 0.6, p_kontur + 0.6, d);
  vec4 c = vec4(c_konturReng, 1.0) * ring; c = mix(c, vec4(c_renk, 1.0), fill * step(0.01, p_belirme)); o = overPre(c * step(0.5, p_belirme), s); }
