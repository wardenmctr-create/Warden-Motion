// cubeface
uniform float p_donus, p_kameraMesa, p_golge, p_ilerleme;
void main() { float p = p_ilerleme / 100.0; float a = radians(p_donus) * p; vec2 b = boxUV(here()) * 2.0 - 1.0; float F = max(p_kameraMesa, 100.0) / max(boxU().x, 1.0) * 2.0;
  // küpün ön yüzü Y ekseni etrafında döner; ışın-düzlem kesişimi
  vec3 ro = vec3(0.0, 0.0, F + 1.0); vec3 rd = normalize(vec3(b.x, -b.y * boxU().y / boxU().x, -F)); vec3 nrm = vec3(sin(a), 0.0, cos(a)); vec3 c0 = vec3(-sin(a), 0.0, -cos(a) + 1.0) * 1.0 + vec3(0.0, 0.0, 0.0);
  vec3 ctr = vec3(0.0, 0.0, 1.0) - vec3(sin(a), 0.0, cos(a)) + vec3(0.0); ctr = vec3(sin(a), 0.0, cos(a)) * 1.0 - vec3(0.0, 0.0, 1.0) + vec3(0.0, 0.0, 1.0) - vec3(0.0, 0.0, 1.0);
  vec3 C = vec3(sin(a), 0.0, cos(a)) - vec3(0.0, 0.0, 1.0) + vec3(0.0, 0.0, 1.0); C = vec3(sin(a), 0.0, cos(a) - 1.0) + vec3(0.0, 0.0, 1.0) * 0.0; float den = dot(rd, nrm); if (abs(den) < 1e-4) { o = vec4(0.0); return; }
  float t = dot(C - ro, nrm) / den; vec3 hp = ro + rd * t; vec3 u = vec3(cos(a), 0.0, -sin(a)); vec2 uv = vec2(dot(hp - C, u), hp.y * boxU().x / boxU().y) * 0.5 + 0.5; uv.y = 1.0 - uv.y;
  if (t < 0.0 || any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0))) || nrm.z < 0.0) { o = vec4(0.0); return; } vec4 c = texPx(boxPx(uv)); if (p_golge > 0.5) c.rgb *= 1.0 - p * 0.6; o = c; }
