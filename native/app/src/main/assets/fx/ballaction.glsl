// ballaction
uniform float p_topAral, p_topBoyu, p_dagilma, p_donusX, p_donusY, p_derinlik, p_isik, p_tohum, p_kaynakReng;
void main() { vec2 q = toUnit(here()); float sp = max(p_topAral, 2.0); vec4 res = vec4(0.0); float sc = 1.0;
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) { vec2 id = floor(q / sp) + vec2(float(i), float(j)); vec2 home = (id + 0.5) * sp; vec4 c = texU(home); if (c.a < 0.1) continue;
    vec3 h = vec3(hash2(id + seedf(p_tohum)), hash1(id + 9.0)) - 0.5; vec3 p3 = vec3(home, 0.0) + h * p_dagilma * vec3(1.0, 1.0, p_derinlik / 50.0);
    float ax = radians(p_donusX), ay = radians(p_donusY); p3.yz = mat2(cos(ax), sin(ax), -sin(ax), cos(ax)) * p3.yz; p3.xz = mat2(cos(ay), -sin(ay), sin(ay), cos(ay)) * p3.xz;
    float r = sp * 0.5 * p_topBoyu / 100.0 * (1.0 + p3.z / 600.0); vec2 rel = q - p3.xy; float d = length(rel); if (d > r) continue;
    vec3 n = vec3(rel / r, sqrt(max(0.0, 1.0 - dot(rel, rel) / (r * r)))); float l = 0.5 + 0.5 * dot(n, normalize(vec3(-0.5, -0.6, 0.8)));
    vec3 col = (p_kaynakReng > 0.5 ? unpre(c) : vec3(0.85)) * mix(1.0, l, p_isik / 100.0) + pow(l, 20.0) * p_isik / 100.0 * 0.5; res = overPre(res, vec4(col, 1.0) * (1.0 - res.a)); }
  o = res; }
