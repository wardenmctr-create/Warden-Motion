// gradpath
uniform vec2 p_baslangi, p_bitis; uniform float p_durakSayi, p_ornekGeni;
// A→B doğrusundan örnek; durak sayısı kadar basamaklı gradyan şeridi kutunun altında, ölçüm çizgisi görüntü üstünde
vec3 sampleAt(float u) { vec2 q = mix(p_baslangi, p_bitis, u); vec2 n = normalize(vec2(-(p_bitis - p_baslangi).y, (p_bitis - p_baslangi).x) + 1e-5); vec3 a = vec3(0.0); for (int i = -2; i <= 2; i++) a += unpre(texU(q + n * float(i) * p_ornekGeni / 4.0)); return a / 5.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 b = boxUV(here()); vec2 q = toUnit(here()); float N = clamp(floor(p_durakSayi), 2.0, 64.0);
  vec2 ab = p_bitis - p_baslangi; float u = clamp(dot(q - p_baslangi, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0); float d = length(q - p_baslangi - ab * u);
  vec4 res = s; float lw = 1.0 / u_s; res = overPre(vec4(1.0) * (1.0 - smoothstep(lw, lw * 2.0, d)), res);
  if (b.y > 0.86 && b.y < 0.98 && b.x > 0.04 && b.x < 0.96) { float x = (b.x - 0.04) / 0.92; float k = floor(x * N) / (N - 1.0); vec3 c = mix(sampleAt(floor(x * N) / N), sampleAt(min(1.0, (floor(x * N) + 1.0) / N)), 0.0); c = sampleAt(k); res = vec4(c, 1.0); }
  o = res; }
