// opticscomp
uniform float p_gorusAcis, p_duzeltmeYonu, p_olcek, p_kenarKirp; uniform vec2 p_merkez;
void main() {
  vec2 B = boxU(); vec2 r = (toUnit(here()) - p_merkez) / (length(B) * 0.5); float d = length(r);
  float f = radians(clamp(p_gorusAcis, 1.0, 179.0)) * 0.5; float k = tan(f);
  float rs = p_duzeltmeYonu < 0.5 ? tan(d * f) / k : atan(d * k) / f;
  vec2 s = d > 1e-5 ? r / d * rs : r; s /= max(p_olcek / 100.0, 0.01);
  vec4 c = texU(p_merkez + s * length(B) * 0.5);
  if (p_kenarKirp > 0.5) { vec2 b = boxUV(fromUnit(p_merkez + s * length(B) * 0.5)); if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) c = vec4(0.0); }
  o = c;
}
