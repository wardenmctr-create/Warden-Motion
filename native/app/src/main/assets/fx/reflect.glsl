// reflect
uniform float p_yansimaEkse, p_kaynakTara, p_birlesimYumu, p_tersKayn; uniform vec2 p_eksenNokt;
void main() {
  vec2 q = toUnit(here()); float a = radians(p_yansimaEkse);
  vec2 n = vec2(-sin(a), cos(a));
  vec2 want = p_kaynakTara < 0.5 ? vec2(-1, 0) : p_kaynakTara < 1.5 ? vec2(1, 0) : p_kaynakTara < 2.5 ? vec2(0, -1) : vec2(0, 1);
  float sg = dot(n, want) >= 0.0 ? 1.0 : -1.0; if (p_tersKayn > 0.5) sg = -sg;
  float d = dot(q - p_eksenNokt, n) * sg;
  vec4 orig = texU(q);
  if (d >= 0.0) { o = orig; return; }
  vec4 r = texU(q - 2.0 * dot(q - p_eksenNokt, n) * n);
  float w = p_birlesimYumu > 0.01 ? smoothstep(0.0, p_birlesimYumu, -d) : 1.0;
  o = mix(orig, r, w);
}
