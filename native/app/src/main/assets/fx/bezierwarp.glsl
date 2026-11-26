// bezierwarp
uniform float p_agYogu, p_kenarlarUzat;
void main() { o = p_kenarlarUzat > 0.5 ? texEdge(here(), 3.0) : texPx(here()); }
