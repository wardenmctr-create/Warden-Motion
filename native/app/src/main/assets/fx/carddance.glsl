// carddance
uniform float p_satir, p_sutun, p_donusX, p_donusY, p_dalgaYonu, p_faz, p_dalgaBoyu, p_frekans, p_perspekt; uniform vec3 c_arkaYuzReng;
void main() {
  vec2 q = toUnit(here()); vec2 B = boxU(); vec2 n = vec2(max(1.0, floor(p_sutun)), max(1.0, floor(p_satir))); vec2 cs = B / n; vec4 res = vec4(0.0);
  vec2 wd = vec2(cos(radians(p_dalgaYonu)), sin(radians(p_dalgaYonu)));
  for (int j = -1; j <= 1; j++) for (int i = -1; i <= 1; i++) {
    vec2 id = floor((q + B * 0.5) / cs) + vec2(float(i), float(j)); if (any(lessThan(id, vec2(0.0))) || any(greaterThanEqual(id, n))) continue; vec2 c = (id + 0.5) * cs - B * 0.5;
    float ph = sin(dot(c, wd) / max(p_dalgaBoyu, 1.0) * TAU - u_t * p_frekans * TAU + radians(p_faz)); float ax = radians(p_donusX * ph), ay = radians(p_donusY * ph);
    // kartın düzlemi: x eksenine (ax) ve y eksenine (ay) göre döner; ışın-düzlem kesişimi (yaklaşık perspektif)
    vec3 nx = vec3(cos(ay), 0.0, -sin(ay)); vec3 ny = vec3(sin(ax) * sin(ay), cos(ax), sin(ax) * cos(ay)); vec3 nn = cross(nx, ny);
    vec3 ro = vec3(q - c, 0.0); float F = max(B.x, B.y) * mix(6.0, 1.2, p_perspekt / 100.0); vec3 rd = normalize(vec3((q - c) * 0.0, 0.0) - vec3(0.0, 0.0, F) + vec3(q - c, 0.0)) ; vec3 eye = vec3(0.0, 0.0, F);
    vec3 dir = normalize(vec3(q - c, 0.0) - eye); float den = dot(nn, dir); if (abs(den) < 1e-4) continue; float t = -dot(nn, eye) / den; vec3 hit = eye + dir * t;
    vec2 uv = vec2(dot(hit, nx), dot(hit, ny)); if (abs(uv.x) > cs.x * 0.5 || abs(uv.y) > cs.y * 0.5) continue;
    vec4 col = texU(c + uv); if (den > 0.0) col = vec4(c_arkaYuzReng, 1.0) * col.a; col.rgb *= 0.75 + 0.25 * abs(nn.z); res = overPre(res, col); }
  o = res;
}
