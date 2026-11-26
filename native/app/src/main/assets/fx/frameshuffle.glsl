// frameshuffle
INCLUDE(_hist)
void main() { o = histN() < 1.0 ? texture(u_tex, v_uv) : hist(0.0, v_uv); }
