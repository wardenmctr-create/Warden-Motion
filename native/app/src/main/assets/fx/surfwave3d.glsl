// surfwave3d
INCLUDE(_3d)
INCLUDE(_card)
uniform vec3 p_kaynak; uniform float p_genlik, p_dalgaBoyu, p_hiz;
// Yüzey boyunca yayılan dalga: kaynaktan yüzey uzaklığına göre z yer değiştirmesi
float hgt(vec2 xy) { float r = length(xy - p_kaynak.xy); float L = max(p_dalgaBoyu, 1.0); return p_genlik * sin(6.2832 * (r - u_t * p_hiz) / L) * exp(-r / (L * 6.0)); }
float sdf(vec3 p) { return cardD(p - vec3(0.0, 0.0, hgt(p.xy)), 20.0) * 0.55; }
vec4 surf(vec3 p, vec3 n) { return cardSurf(p, n); }
void main() { o = render3d(vec3(0.0)); }
