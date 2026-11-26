// decimate
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_yuzOran, p_kenarKoru, p_onceSonrYuz;
float sdf(vec3 p) { float N = mix(6.0, 64.0, p_yuzOran / 100.0); float a = atan(p.y, p.x); float sec = TAU / N; float a0 = floor(a / sec) * sec, a1 = a0 + sec; float R = length(boxU()) * 0.5;
  float r0 = 0.0, r1 = 0.0; for (int k = 0; k < 24; k++) { float t = R * float(k) / 23.0; if (cardA(vec2(cos(a0), sin(a0)) * t) > 0.5) r0 = t; if (cardA(vec2(cos(a1), sin(a1)) * t) > 0.5) r1 = t; }
  vec2 A = vec2(cos(a0), sin(a0)) * r0, B = vec2(cos(a1), sin(a1)) * r1; vec2 e = B - A; float side = (e.x * (p.y - A.y) - e.y * (p.x - A.x)) / max(length(e), 1e-3); float d2 = -side; return max(d2, abs(p.z) - 10.0); }
vec4 surf(vec3 p, vec3 n) { vec4 c = cardSurf(p, n); if (p_onceSonrYuz > 0.5) { float N = mix(6.0, 64.0, p_yuzOran / 100.0); float a = atan(p.y, p.x); float f = fract(a / (TAU / N)); c.rgb *= 1.0 - (1.0 - smoothstep(0.0, 0.03, min(f, 1.0 - f))) * 0.4; } return c; }
void main() { o = render3d(vec3(0.0)); }
