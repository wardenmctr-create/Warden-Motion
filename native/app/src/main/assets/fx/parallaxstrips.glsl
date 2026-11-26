// parallaxstrips
uniform float p_serit, p_derinlikFark, p_yon, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; vec2 d = vec2(cos(radians(p_yon)), sin(radians(p_yon))); vec2 n = vec2(-d.y, d.x); vec2 q = toUnit(here()); float N = max(floor(p_serit), 2.0); float B = dot(abs(n), boxU());
  float id = floor((dot(q, n) / B + 0.5) * N); float depth = 1.0 + hash1(vec2(id, 3.0)) * p_derinlikFark / 50.0; vec2 sq = q - d * p * depth * dot(abs(d), boxU()) * 1.3; o = texU(sq); }
