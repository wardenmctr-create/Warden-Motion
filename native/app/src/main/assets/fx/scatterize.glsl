// scatterize
uniform float p_ilerleme, p_parcaBoyu, p_ruzgarYonu, p_savrulma, p_turbulan, p_kenarGeci, p_tohum, p_otomatik, p_sure;
void main() {
  vec2 q = toUnit(here()); float pr = p_otomatik > 0.5 ? clamp(u_t / max(p_sure, 0.05), 0.0, 1.0) : p_ilerleme / 100.0; if (pr <= 0.0) { o = texture(u_tex, v_uv); return; }
  vec2 dir = vec2(cos(radians(p_ruzgarYonu)), sin(radians(p_ruzgarYonu))); float ps = max(p_parcaBoyu, 0.5); vec4 res = vec4(0.0); vec2 B = boxU();
  for (int k = 0; k < 12; k++) { float t = float(k) / 11.0; vec2 src = q - dir * p_savrulma * pr * t * 1.2; vec2 id = floor(src / ps); float h = hash1(id + seedf(p_tohum));
    float start = clamp(dot(src / B + 0.5, dir) * (1.0 - p_kenarGeci / 100.0) + h * p_kenarGeci / 100.0, 0.0, 1.0); float pp = clamp((pr * 1.4 - start * 0.9) / 0.6, 0.0, 1.0);
    vec2 turb = vec2(pnoise(id * 0.1 + 3.0), pnoise(id * 0.1 + 9.0)) * p_turbulan / 100.0 * p_savrulma * 0.3 * pp;
    vec2 pos = (id + 0.5) * ps + dir * p_savrulma * pp + turb; if (length(q - pos) < ps * 0.6) { vec4 c = texU((id + 0.5) * ps) * (1.0 - pp); res = max(res, c); } }
  o = res;
}
