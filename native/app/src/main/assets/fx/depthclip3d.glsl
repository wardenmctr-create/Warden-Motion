// depthclip3d
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_yakinSini, p_uzakSini, p_gecis;
float sdf(vec3 p) { return cardD(p, 16.0); }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { vec4 c = render3d(vec3(0.0)); float z = (p_kameraUzak > 0.0 ? p_kameraUzak : 800.0); float near = smoothstep(p_yakinSini - p_gecis * 0.5 - 1e-3, p_yakinSini + p_gecis * 0.5 + 1e-3, z); float far = 1.0 - smoothstep(p_uzakSini - p_gecis * 0.5 - 1e-3, p_uzakSini + p_gecis * 0.5 + 1e-3, z);
  o = c * near * far; }
