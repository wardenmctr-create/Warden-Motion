// Ayrılabilir Gauss bulanıklığı (bir yön). Büyük yarıçapta adım büyür (en çok 48 örnek)
uniform vec2 u_dir; uniform float u_sigma;
void main() {
  if (u_sigma < 0.3) { o = texture(u_tex, v_uv); return; }
  float stepPx = max(1.0, u_sigma / 8.0);
  int n = int(min(24.0, ceil(u_sigma * 3.0 / stepPx)));
  vec4 acc = vec4(0.0); float wsum = 0.0;
  for (int i = -24; i <= 24; i++) {
    if (i < -n || i > n) continue;
    float x = float(i) * stepPx; float w = exp(-0.5 * x * x / (u_sigma * u_sigma));
    acc += tex(v_uv + u_dir * x / u_res) * w; wsum += w;
  }
  o = acc / wsum;
}
