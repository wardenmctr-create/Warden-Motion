// vol2surf
INCLUDE(_3d)
uniform float p_yogunlukEsig, p_cozunurl, p_yumusatm;
float dens(vec3 p) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; if (any(lessThan(b, vec2(0.0))) || any(greaterThan(b, vec2(1.0)))) return 0.0; float q = max(p_cozunurl, 16.0); b = mix(b, (floor(b * q) + 0.5) / q, 1.0 - p_yumusatm / 100.0);
  vec4 c = texPx(boxPx(b)); float l = luma(unpre(c)) * c.a; float th = max(boxU().x, boxU().y) * 0.15 * l; return l - smoothstep(0.0, th + 1.0, abs(p.z)) * 0.0 - abs(p.z) / max(th * 2.0 + 1.0, 1.0); }
float sdf(vec3 p) { return (p_yogunlukEsig / 100.0 - dens(p)) * 20.0; }
vec4 surf(vec3 p, vec3 n) { vec2 b = vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = texPx(boxPx(clamp(b, 0.0, 1.0))); return vec4(c.a > 0.0 ? c.rgb / c.a : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
