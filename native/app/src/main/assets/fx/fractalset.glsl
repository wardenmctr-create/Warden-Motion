// fractalset
GRADIENT(palet)
uniform float p_fraktalTuru, p_yakinlas, p_yineleme, p_faz, p_yumusakRenk; uniform vec2 p_merkez, p_juliaSabi;
void main() {
  vec2 b = boxUV(here()) - 0.5; vec2 B = boxU(); b.x *= B.x / B.y;
  vec2 c = p_merkez + b * 3.0 / max(p_yakinlas, 1e-6);
  vec2 z = p_fraktalTuru > 0.5 ? c : vec2(0.0); vec2 k = p_fraktalTuru > 0.5 ? p_juliaSabi : c;
  float n = 0.0; int N = int(clamp(p_yineleme, 8.0, 512.0)); bool esc = false;
  for (int i = 0; i < 512; i++) { if (i >= N) break; z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + k; if (dot(z, z) > 256.0) { esc = true; break; } n += 1.0; }
  float v = n; if (p_yumusakRenk > 0.5 && esc) v = n - log2(log2(dot(z, z))) + 4.0;
  vec3 col = esc ? grad_palet(fract(v / 48.0 + p_faz / 100.0)) : vec3(0.0);
  o = genOver(vec4(col, 1.0));
}
