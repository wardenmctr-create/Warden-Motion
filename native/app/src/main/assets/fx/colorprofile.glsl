// colorprofile
uniform float p_girisProf, p_cikisProf, p_gamutEsle, p_siyahNoktTela;
mat3 toXYZ(float k) { if (k < 1.5) return mat3(0.4124, 0.2126, 0.0193, 0.3576, 0.7152, 0.1192, 0.1805, 0.0722, 0.9505); if (k < 2.5) return mat3(0.4866, 0.2290, 0.0, 0.2657, 0.6917, 0.0451, 0.1982, 0.0793, 1.0439); if (k < 3.5) return mat3(0.4124, 0.2126, 0.0193, 0.3576, 0.7152, 0.1192, 0.1805, 0.0722, 0.9505); return mat3(0.6370, 0.2627, 0.0, 0.1446, 0.6780, 0.0281, 0.1689, 0.0593, 1.0610); }
void main() {
  vec4 s = texture(u_tex, v_uv); if (s.a <= 0.0) { o = s; return; }
  float gi = p_girisProf < 0.5 ? 1.0 : p_girisProf; float go = p_cikisProf + 1.0;
  vec3 l = srgb2lin(unpre(s)); vec3 x = toXYZ(gi) * l; vec3 r = inverse(toXYZ(go)) * x;
  if (p_gamutEsle < 0.5) { float m = max(r.r, max(r.g, r.b)); if (m > 1.0) r /= m; } else if (p_gamutEsle < 1.5) { float lm = dot(r, vec3(0.2126, 0.7152, 0.0722)); r = mix(vec3(lm), r, 0.92); }
  o = pre(clamp(lin2srgb(r), 0.0, 1.0), s.a);
}
