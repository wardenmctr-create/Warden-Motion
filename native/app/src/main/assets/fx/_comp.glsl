// Katmanı sahneye koyar (dönüşüm köşe programında). u_op: opaklık
uniform float u_op;
void main() { o = texture(u_tex, v_uv) * u_op; }
