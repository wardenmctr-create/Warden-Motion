// wireremove
uniform vec2 p_baslangi, p_bitis; uniform float p_cizgiKali, p_ornekUzak, p_yontem, p_kenarYumu;
void main() { vec4 s = texture(u_tex, v_uv); vec2 q = toUnit(here()); vec2 ab = p_bitis - p_baslangi; float t = clamp(dot(q - p_baslangi, ab) / max(dot(ab, ab), 1.0), 0.0, 1.0); vec2 c = p_baslangi + ab * t; float d = length(q - c);
  float w = p_cizgiKali * 0.5; float m = 1.0 - smoothstep(w, w + max(p_kenarYumu, 0.3), d); if (m <= 0.0) { o = s; return; }
  vec2 n = normalize(vec2(-ab.y, ab.x) + 1e-5); float off = w + p_ornekUzak; vec4 f = (texU(c + n * off) + texU(c - n * off)) * 0.5;
  if (p_yontem > 0.5) { float k = dot(q - c, n) / max(off, 1.0) * 0.5 + 0.5; f = mix(texU(c - n * off), texU(c + n * off), clamp(k, 0.0, 1.0)); } o = mix(s, f, m); }
