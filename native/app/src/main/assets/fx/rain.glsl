// rain
uniform float p_yogunluk, p_damlaUzun, p_kalinlik, p_hiz, p_aci, p_opaklik, p_tohum, p_alfayaKirp; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = rot2(-p_aci) * toUnit(here()); float acc = 0.0; float cw = mix(14.0, 4.0, clamp(p_yogunluk / 1000.0, 0.0, 1.0));
  for (int l = 0; l < 2; l++) { float col = floor(q.x / cw); float h = hash1(vec2(col, seedf(p_tohum) + float(l) * 3.0)); float sp = p_hiz * (0.7 + 0.6 * h) * (1.0 - float(l) * 0.3);
    float per = p_damlaUzun * 4.0 + 60.0; float y = mod(q.y - u_t * sp - h * per * 7.0, per); float x = abs(fract(q.x / cw) - 0.5) * cw;
    float k = (1.0 - smoothstep(p_kalinlik * 0.5, p_kalinlik * 0.5 + 0.6 / u_s, x)) * step(y, p_damlaUzun) * (y / max(p_damlaUzun, 1.0)); acc = max(acc, k * (1.0 - float(l) * 0.4)); }
  vec4 f = vec4(c_renk, 1.0) * acc * p_opaklik / 100.0; if (p_alfayaKirp > 0.5) f *= s.a; o = overPre(f, s);
}
