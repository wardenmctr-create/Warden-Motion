// daynight
uniform float p_tarih[3]; uniform float p_tarihN, p_utcSaat, p_alacakar, p_geceOpak;
// Eşdikdörtgen dünya haritası: tarih → güneş sapması, UTC saat → güneş altı boylam; güneş yüksekliğine göre gece ve alacakaranlık
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); float lon = (b.x - 0.5) * 360.0, lat = (0.5 - b.y) * 180.0; float Y = p_tarihN > 0.5 ? abs(p_tarih[0]) : 2026.0; float Mo = p_tarihN > 1.5 ? abs(p_tarih[1]) : 1.0; float D = p_tarihN > 2.5 ? abs(p_tarih[2]) : 1.0;
  float doy = floor(275.0 * Mo / 9.0) - (Mo > 2.0 ? (mod(Y, 4.0) == 0.0 ? 1.0 : 2.0) : 0.0) * floor((Mo + 9.0) / 12.0) + D - 30.0; float dec = -23.44 * cos(6.28318 / 365.0 * (doy + 10.0)); float slon = (12.0 - p_utcSaat) * 15.0;
  float alt = degrees(asin(clamp(sin(radians(lat)) * sin(radians(dec)) + cos(radians(lat)) * cos(radians(dec)) * cos(radians(lon - slon)), -1.0, 1.0)));
  float night = smoothstep(0.0, -max(p_alacakar, 0.1), alt); float term = 1.0 - smoothstep(0.0, 0.8, abs(alt)); vec3 c = mix(s.rgb, s.rgb * vec3(0.25, 0.3, 0.55), night * p_geceOpak / 100.0); c += vec3(1.0, 0.7, 0.3) * term * 0.25 * s.a; o = vec4(c, s.a); }
