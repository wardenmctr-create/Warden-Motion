// stretchseg
uniform vec2 p_merkez; uniform float p_seritGeni, p_esneme, p_aci, p_gecis, p_oraniKoru;
void main() {
  vec2 q = toUnit(here()); float a = radians(p_aci + 90.0); vec2 d = vec2(cos(a), sin(a)), n = vec2(-d.y, d.x);
  vec2 r = q - p_merkez; float s = dot(r, d), m = dot(r, n);
  float hw = max(p_seritGeni, 0.5) * 0.5; float E = p_seritGeni * p_esneme / 100.0; float ho = max(0.5, hw + E * 0.5);
  float ss = abs(s) < ho ? s * hw / ho : s - sign(s) * E * 0.5;
  if (p_gecis > 0.01) { float k = smoothstep(ho, ho + p_gecis, abs(s)); ss = mix(abs(s) < ho ? s * hw / ho : sign(s) * hw, ss, k); if (abs(s) < ho) ss = s * hw / ho; }
  float mm = (p_oraniKoru > 0.5 && abs(s) < ho) ? m * hw / ho : m;
  o = texU(p_merkez + d * ss + n * mm);
}
