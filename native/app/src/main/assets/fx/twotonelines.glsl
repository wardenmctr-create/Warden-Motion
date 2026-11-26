// twotonelines
uniform vec3 c_aydinlik, c_golge; uniform float p_isikAcis, p_cizgiKali, p_gecis;
// Koyu çizginin ışığa bakan kenarı açık, karşı kenarı koyu renkle boyanır
float ink(vec2 p) { vec4 c = texPx(p); return c.a > 0.5 && luma(unpre(c)) < 0.35 ? 1.0 : 0.0; }
void main() { vec4 s = texture(u_tex, v_uv); vec2 p = here(); if (ink(p) < 0.5) { o = s; return; } float W = max(p_cizgiKali * u_s, 1.0); float la = radians(p_isikAcis); vec2 L = vec2(cos(la), -sin(la));
  float toLight = 1e5, toShade = 1e5; for (int k = 1; k <= 10; k++) { float r = float(k) / 10.0 * W * 2.0; if (toLight > 9e4 && ink(p + L * r) < 0.5) toLight = r; if (toShade > 9e4 && ink(p - L * r) < 0.5) toShade = r; }
  float sw = max(p_gecis / 100.0, 0.02); float lightSide = smoothstep(0.5 + sw, 0.5 - sw, toLight / max(toLight + toShade, 1e-3)); vec3 c = mix(c_golge, c_aydinlik, lightSide);
  float rim = step(min(toLight, toShade), W); o = pre(mix(unpre(s), c, rim), s.a); }
