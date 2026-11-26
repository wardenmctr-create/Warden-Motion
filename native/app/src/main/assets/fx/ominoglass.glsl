// ominoglass
uniform sampler2D s_dokuKatm; uniform float p_dokuKatmOn;
uniform float p_kirilma, p_prizmaAyri, p_dokuOlce, p_camKali, p_kenarYumu, p_tersHari;
void main() {
  vec2 q = toUnit(here()); float s = max(p_dokuOlce, 2.0);
  vec2 nrm;
  if (p_dokuKatmOn > 0.5) { vec2 b = clamp(boxUV(here()), 0.0, 1.0); vec2 e = 2.0 / u_box.zw;
    float hx = luma(unpre(texture(s_dokuKatm, b + vec2(e.x, 0.0)))) - luma(unpre(texture(s_dokuKatm, b - vec2(e.x, 0.0))));
    float hy = luma(unpre(texture(s_dokuKatm, b + vec2(0.0, e.y)))) - luma(unpre(texture(s_dokuKatm, b - vec2(0.0, e.y)))); nrm = vec2(hx, hy) * 4.0; }
  else {
    // omino karoları: farklı boy kare bloklar, her biri eğik bir cam yüzeyi
    vec2 id = floor(q / s); float big = step(0.6, hash1(floor(id / 2.0) + 3.1));
    vec2 cid = big > 0.5 ? floor(id / 2.0) * 2.0 : id; vec2 cs = vec2(big > 0.5 ? 2.0 * s : s);
    vec2 f = (q - cid * s) / cs; vec2 r = hash2(cid + 11.0) - 0.5;
    float edge = min(min(f.x, 1.0 - f.x), min(f.y, 1.0 - f.y)); float bev = smoothstep(0.0, max(p_camKali, 0.5) / cs.x, edge);
    nrm = r * 0.8 + (1.0 - bev) * (f - 0.5) * 2.0 * (p_kenarYumu > 0.0 ? 1.0 : 1.5);
  }
  if (p_tersHari > 0.5) nrm = -nrm;
  vec2 dd = nrm * p_kirilma; vec2 pa = nrm * p_prizmaAyri;
  vec4 g = texU(q + dd);
  o = vec4(texU(q + dd + pa).r, g.g, texU(q + dd - pa).b, max(g.a, texU(q).a * 0.0 + g.a));
}
