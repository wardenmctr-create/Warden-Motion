// depthpointsize
uniform sampler2D s_noktaBulu; uniform float p_noktaBuluOn, p_yakinBoyu, p_uzakBoyu, p_yogunlukKoru;
// Nokta bulutu: kaynak (ya da katman) ızgara örnekleri; derinlik = parlaklık; yakın noktalar büyük, uzak küçük; yavaş paralaks
vec4 S(vec2 u) { return p_noktaBuluOn > 0.5 ? texture(s_noktaBulu, u) : texPx(boxPx(u)); }
void main() { vec2 q = here(); float sp = max(min(u_box.z, u_box.w) / 60.0, 3.0); vec2 id0 = floor((q - u_box.xy) / sp); float v = 0.0; vec3 col = vec3(0.0);
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) { vec2 id = id0 + vec2(i, j); vec2 u = (id + 0.5) * sp / u_box.zw; if (any(lessThan(u, vec2(0.0))) || any(greaterThan(u, vec2(1.0)))) continue; vec4 c = S(u); if (c.a < 0.3) continue;
    float z = luma(unpre(c)); vec2 pos = u_box.xy + (id + 0.5) * sp + vec2(sin(u_t * 0.6), 0.0) * (z - 0.5) * sp * 1.5; float sz = mix(p_uzakBoyu, p_yakinBoyu, z) * u_s * 0.5; sz = mix(sz, sz * sp / max(sz * 2.0, 1.0), p_yogunlukKoru / 100.0 * 0.5);
    float a = 1.0 - smoothstep(sz - 0.7, sz + 0.7, length(q - pos)); if (a > v) { v = a; col = unpre(c) * (0.6 + 0.4 * z); } }
  o = vec4(col * v, v); }
