// linwipe
uniform float p_ilerleme, p_aci, p_yumusatm, p_ters, p_mod, p_basSinir, p_bitSinir, p_sinirBagla, p_kenarCizgi, p_kenarKalin, p_kenarParla, p_parlaBuyu; uniform vec3 c_kenarRenk;
void main() {
  vec4 s = texture(u_tex, v_uv); vec2 d = vec2(cos(radians(p_aci)), sin(radians(p_aci))); vec2 B = boxU(); float span = abs(d.x) * B.x + abs(d.y) * B.y + p_yumusatm * 2.0;
  float x = dot(toUnit(here()), d) / span + 0.5; float lo = p_basSinir / 100.0, hi = p_sinirBagla > 0.5 ? 1.0 - lo : p_bitSinir / 100.0;
  float e = mix(lo, hi, p_ilerleme / 100.0); float w = p_yumusatm / span * 0.5 + 1e-4; float k, dist;
  if (p_mod < 0.5) { k = smoothstep(e - w, e + w, x); dist = abs(x - e); }
  else if (p_mod < 1.5) { float h = (e - lo) * 0.5; k = smoothstep(lo + h - w, lo + h + w, x) * (1.0 - smoothstep(hi - h - w, hi - h + w, x)); dist = min(abs(x - lo - h), abs(x - hi + h)); }
  else { float c = (lo + hi) * 0.5; float h = (e - lo) * 0.5; k = smoothstep(h - w, h + w, abs(x - c)); dist = abs(abs(x - c) - h); }
  if (p_ters > 0.5) k = 1.0 - k;
  vec4 c = s * k; float px = dist * span; bool moving = p_ilerleme > 0.1 && p_ilerleme < 99.9;
  if (p_kenarCizgi > 0.5 && moving) c = overPre(vec4(c_kenarRenk, 1.0) * (1.0 - smoothstep(p_kenarKalin * 0.5, p_kenarKalin * 0.5 + 0.8, px)) * s.a, c);
  if (p_kenarParla > 0.5 && moving) { float g = exp(-px / max(p_parlaBuyu * 0.4, 0.5)) * s.a; c.rgb += c_kenarRenk * g * 0.8; c.a = max(c.a, g * 0.8); }
  o = c;
}
