// screeninscreen
uniform sampler2D s_hedefKlip; uniform float p_hedefKlipOn, p_ekranKose, p_ilerleme;
// İlk görüntünün içindeki ekran (merkezde dörtgen) ikinci klibi gösterir; ilerledikçe kamera ekrana yaklaşır ve ekran tuvali doldurur
void main() { vec2 b = boxUV(here()); float k = smoothstep(0.0, 1.0, p_ilerleme / 100.0); vec2 slo = vec2(0.3, 0.32), shi = vec2(0.7, 0.62); vec2 vlo = mix(vec2(0.0), slo, k), vhi = mix(vec2(1.0), shi, k);
  vec2 uv = vlo + b * (vhi - vlo); vec2 sb = (uv - slo) / (shi - slo);
  if (all(greaterThanEqual(sb, vec2(0.0))) && all(lessThanEqual(sb, vec2(1.0)))) { vec4 t = p_hedefKlipOn > 0.5 ? texture(s_hedefKlip, sb) : vec4(vec3(0.2, 0.6, 1.0) * (0.6 + 0.4 * sb.y), 1.0);
    float frame = 1.0 - step(0.015, min(min(sb.x, 1.0 - sb.x), min(sb.y, 1.0 - sb.y))); o = mix(t, vec4(0.05, 0.05, 0.06, 1.0), frame * (1.0 - k)); } else o = texPx(boxPx(uv)); }
