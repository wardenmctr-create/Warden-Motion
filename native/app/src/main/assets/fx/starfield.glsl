// starfield
uniform float p_yildizSayi, p_hiz, p_yildizBoyu, p_derinlik, p_izler, p_izUzun, p_tohum; uniform vec2 p_merkez; uniform vec3 c_renk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()) - p_merkez; float R = length(boxU()) * 0.5; vec2 p = q / R;
  float acc = 0.0; float layers = 4.0; float dens = sqrt(clamp(p_yildizSayi, 10.0, 5000.0) / 300.0);
  for (int l = 0; l < 4; l++) { float z = fract(float(l) / layers - u_t * p_hiz * 0.15); float sc = mix(18.0, 1.0, z) * dens; vec2 g = p * sc; vec2 id = floor(g);
    for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 cid = id + vec2(float(i), float(j)); vec2 sp = (cid + hash2(cid + float(l) * 17.0 + seedf(p_tohum))) / sc;
      if (hash1(cid + float(l)) > 0.6) continue; float rad = p_yildizBoyu / R * mix(0.3, 1.6, z) * 0.5; vec2 dv = p - sp;
      if (p_izler > 0.5) { vec2 dir = normalize(sp + 1e-4); float u = clamp(dot(dv, dir), -p_izUzun / R * z, 0.0); dv -= dir * u; }
      float b = (1.0 - smoothstep(rad * 0.3, rad, length(dv))) * mix(1.0 - p_derinlik / 100.0, 1.0, z) * smoothstep(0.0, 0.15, z) * smoothstep(1.0, 0.85, z); acc = max(acc, b); } }
  o = overPre(vec4(c_renk, 1.0) * acc, s);
}
