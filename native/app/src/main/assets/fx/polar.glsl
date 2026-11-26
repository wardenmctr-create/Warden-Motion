// polar
uniform float p_donusum, p_miktar, p_aci, p_tersYon; uniform vec2 p_merkez;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); float rad = min(B.x, B.y) * 0.5;
  vec2 src;
  if (p_donusum < 0.5) { // dikdörtgenden kutupsala: kutu daireye sarılır
    vec2 rel = q - p_merkez; float th = atan(rel.y, rel.x) - radians(p_aci) + PI * 0.5;
    float u = fract(th / TAU); if (p_tersYon > 0.5) u = 1.0 - u;
    float v = length(rel) / rad;
    src = v > 1.0 ? vec2(1e5) : (vec2(u, v) - 0.5) * B;
  } else {               // kutupsaldan dikdörtgene: daire açılır
    vec2 b = boxUV(here()); float u = p_tersYon > 0.5 ? 1.0 - b.x : b.x;
    float th = u * TAU + radians(p_aci) - PI * 0.5; float r = b.y * rad;
    src = p_merkez + r * vec2(cos(th), sin(th));
  }
  o = texU(mix(q, src, p_miktar / 100.0));
}
