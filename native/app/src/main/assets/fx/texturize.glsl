// texturize
INCLUDE(_mat)
uniform sampler2D s_ozelDoku; uniform float p_ozelDokuOn;
uniform float p_dokuTuru, p_dokuTohum, p_dokuGucu, p_dokuOlcek, p_dokuAci, p_kaydirX, p_kaydirY, p_tekrar, p_dikisGizle, p_kabartma, p_kabartmaAci, p_kabartmaYogun, p_lif, p_buruskluk,
  p_renkleBirles, p_dokuOpak, p_tersDoku, p_sadeceAydin, p_sadeceGolge; uniform vec3 c_dokuRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  const int MAP[14] = int[14](18, 1, 3, 4, 6, 5, 7, 19, 20, 12, 10, 11, 21, 17); int id = MAP[int(clamp(p_dokuTuru, 0.0, 13.0))];
  vec2 p = rot2(-p_dokuAci) * (toUnit(here()) - vec2(p_kaydirX, p_kaydirY)) / max(p_dokuOlcek / 100.0, 0.05); float sd = seedf(p_dokuTohum);
  vec4 sp = vec4(0.3, 0.6, 0.0, 0.5); float fib = p_lif / 100.0, cr = p_buruskluk / 100.0;
  vec3 mc; float h;
  if (id == 17) { vec2 tuv = p / 200.0; if (p_tekrar > 0.5) tuv = fract(tuv); else tuv = clamp(tuv + 0.5, 0.0, 1.0); vec4 t = p_ozelDokuOn > 0.5 ? texture(s_ozelDoku, tuv) : vec4(0.8); mc = unpre(t); h = luma(mc); }
  else { vec4 m = matSample(id, p, sd, sp, fib, cr); mc = m.rgb; h = m.a; }
  if (p_tersDoku > 0.5) h = 1.0 - h;
  float light = id == 17 ? 1.0 + (h - 0.5) * p_kabartma * 0.1 : matLight(id, p, sd, sp, fib, cr, p_kabartma * (0.3 + p_kabartmaYogun / 100.0 * 2.0), p_kabartmaAci);
  vec3 c = unpre(s); float l = luma(c);
  float w = p_dokuGucu / 100.0 * p_dokuOpak / 100.0; if (p_sadeceAydin > 0.5) w *= smoothstep(0.3, 0.8, l); if (p_sadeceGolge > 0.5) w *= 1.0 - smoothstep(0.2, 0.7, l);
  vec3 tint = mc / max(matBase(id), vec3(0.05)) * c_dokuRenk; // doku açık-koyu değişimi (doğal renk 1'e yakın)
  vec3 r = p_renkleBirles > 0.5 ? c * mix(vec3(1.0), tint * light, w) : mix(c, mc * c_dokuRenk * light, w);
  o = pre(clamp(r, 0.0, 1.0), s.a);
}
