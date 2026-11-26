// spherify
INCLUDE(_3d)
INCLUDE(_card)
uniform float p_hedefSeki, p_guc, p_yaricap;
float tgt(vec3 p) { float R = max(p_yaricap, 1.0); if (p_hedefSeki < 0.5) return length(p) - R; if (p_hedefSeki < 1.5) return max(length(p.xz) - R, abs(p.y) - R); vec3 d = abs(p) - R; return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0); }
float sdf(vec3 p) { float k = p_guc / 100.0; return mix(cardD(p, 14.0), tgt(p), k) * (1.0 - 0.3 * k); }
vec4 surf(vec3 p, vec3 n) { vec2 uv = p_guc > 50.0 ? vec2(atan(p.x, p.z) / TAU + 0.5, 0.5 - asin(clamp(p.y / max(length(p), 1e-3), -1.0, 1.0)) / PI) : vec2(p.x, -p.y) / boxU() + 0.5; vec4 c = layerAt(clamp(uv, 0.0, 1.0)); return vec4(c.a > 0.0 ? c.rgb : c_tabanRenk, 1.0); }
void main() { o = render3d(vec3(0.0)); }
