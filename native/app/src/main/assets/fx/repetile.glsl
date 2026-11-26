// repetile
uniform float p_solUzat, p_sagUzat, p_ustUzat, p_altUzat, p_doseme, p_birlesimYumu; uniform vec2 p_faz;
void main() {
  vec2 b = boxUV(here()); vec2 B = boxU();
  float l = -p_solUzat / B.x, r = 1.0 + p_sagUzat / B.x, t = -p_ustUzat / B.y, bo = 1.0 + p_altUzat / B.y;
  if (b.x < l || b.x > r || b.y < t || b.y > bo) { o = vec4(0.0); return; }
  b -= p_faz / 100.0;
  float m = p_doseme < 0.5 ? 2.0 : p_doseme < 1.5 ? 1.0 : 3.0;
  vec4 c = texEdge(boxPx(b), m);
  if (p_birlesimYumu > 0.5) { vec2 f = fract(b); float e = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)); vec4 c2 = texEdge(boxPx(b + 0.5), m); c = mix(c2, c, smoothstep(0.0, 0.05, e)); }
  o = c;
}
