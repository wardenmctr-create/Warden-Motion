// Warden Motion efekt laboratuvarı: uygulamadaki GPU motorunun WebGL2 eşi.
// Aynı shader dosyalarını (app/src/main/assets/fx) ve aynı kataloğu kullanır.
const FX = window.FXBASE || 'fx/';
const VS = `#version 300 es
in vec2 a_pos; out vec2 v_uv; uniform mat3 u_m;
void main(){ v_uv = a_pos; vec3 p = u_m * vec3(a_pos, 1.0); gl_Position = vec4(p.xy, 0.0, 1.0); }`;

function gradientExpand(src) {
  return src.replace(/^GRADIENT\((\w+)\)\s*$/mg, (m, k) => {
    const N = [...Array(32).keys()]; const c = N.map((i) => `c_${k}${i}`).join(', '), q = N.map((i) => `p_${k}P${i}`).join(', ');
    return `uniform float p_${k}N; uniform vec3 ${c}; uniform float ${q};
vec3 grad_${k}(float x) { vec3 c[32] = vec3[32](${c}); float q[32] = float[32](${q}); int n = int(max(1.0, p_${k}N));
  vec3 r = c[0]; if (x <= q[0]) return c[0]; for (int i = 1; i < 32; i++) { if (i >= n) break; if (x <= q[i]) return mix(c[i - 1], c[i], clamp((x - q[i - 1]) / max(1e-4, q[i] - q[i - 1]), 0.0, 1.0)); r = c[i]; } return r; }
int paln_${k}() { return int(clamp(p_${k}N, 1.0, 32.0)); }
vec3 palc_${k}(int i) { vec3 c[32] = vec3[32](${c}); return c[clamp(i, 0, 31)]; }`;
  });
}
class Engine {
  constructor(canvas) {
    this.c = canvas; const gl = this.gl = canvas.getContext('webgl2', { premultipliedAlpha: true, preserveDrawingBuffer: true, alpha: true });
    gl.getExtension('EXT_color_buffer_float');
    this.quad = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, this.quad);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([0,0, 1,0, 0,1, 1,1]), gl.STATIC_DRAW);
    this.progs = {}; this.src = {};
  }
  async load(catalogUrl) {
    this.common = await (await fetch(FX + 'common.glsl')).text();
    this.cat = await (await fetch(catalogUrl)).json();
    let leg = {}; try { leg = await (await fetch(window.LEGACY || 'legacy.json')).json(); } catch (e) {}
    // Shader'ı henüz rehbere göre yazılmamış efektler eski ayarlarıyla çalışır
    this.meta = {}; for (const e of this.cat.effects) this.meta[e.type] = (!e.ready && leg[e.type]) ? { ...e, ...leg[e.type] } : e;
  }
  async shaderSrc(name) {
    if (!this.src[name]) { let t = await (await fetch(FX + name + '.glsl')).text();
      for (let guard = 0; guard < 4; guard++) { const ms = [...t.matchAll(/^INCLUDE\((\w+)\)\s*$/mg)]; if (!ms.length) break;
        for (const m of ms) t = t.replace(m[0], await (await fetch(FX + m[1] + '.glsl')).text()); }
      this.src[name] = t; }
    return this.src[name]; }
  async prog(name) {
    if (this.progs[name]) return this.progs[name];
    const gl = this.gl; const fsrc = '#version 300 es\n' + this.common + '\n' + gradientExpand(await this.shaderSrc(name));
    const mk = (t, s) => { const sh = gl.createShader(t); gl.shaderSource(sh, s); gl.compileShader(sh); if (!gl.getShaderParameter(sh, gl.COMPILE_STATUS)) throw new Error(name + ': ' + gl.getShaderInfoLog(sh)); return sh; };
    const p = gl.createProgram(); gl.attachShader(p, mk(gl.VERTEX_SHADER, VS)); gl.attachShader(p, mk(gl.FRAGMENT_SHADER, fsrc)); gl.linkProgram(p);
    if (!gl.getProgramParameter(p, gl.LINK_STATUS)) throw new Error(name + ' link: ' + gl.getProgramInfoLog(p));
    this.progs[name] = p; return p;
  }
  tex(w, h) {
    const gl = this.gl; const t = gl.createTexture(); gl.bindTexture(gl.TEXTURE_2D, t);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    for (const [k, v] of [[gl.TEXTURE_MIN_FILTER, gl.LINEAR], [gl.TEXTURE_MAG_FILTER, gl.LINEAR], [gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE], [gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE]]) gl.texParameteri(gl.TEXTURE_2D, k, v);
    const fb = gl.createFramebuffer(); gl.bindFramebuffer(gl.FRAMEBUFFER, fb); gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, t, 0);
    return { t, fb, w, h };
  }
  upload(canvas2d) {
    const gl = this.gl; const T = this.tex(canvas2d.width, canvas2d.height);
    gl.bindTexture(gl.TEXTURE_2D, T.t); gl.pixelStorei(gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA8, gl.RGBA, gl.UNSIGNED_BYTE, canvas2d); return T;
  }
  async assetTex(n) {
    this.atex = this.atex || {}; if (this.atex[n]) return this.atex[n];
    const img = new Image(); img.src = FX + 'tex/' + n.slice(2) + '.png'; await img.decode();
    const c = document.createElement('canvas'); c.width = img.width; c.height = img.height; c.getContext('2d').drawImage(img, 0, 0);
    const T = this.upload(c); const gl = this.gl; gl.bindTexture(gl.TEXTURE_2D, T.t); gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT); this.atex[n] = T; return T;
  }
  free(T) { const gl = this.gl; gl.deleteTexture(T.t); gl.deleteFramebuffer(T.fb); }
  // Bir geçiş: program, girişler, çıktı hedefi
  async pass(name, out, inputs, uni, m) {
    const gl = this.gl; const p = await this.prog(name); gl.useProgram(p);
    gl.bindFramebuffer(gl.FRAMEBUFFER, out ? out.fb : null); gl.viewport(0, 0, out ? out.w : this.c.width, out ? out.h : this.c.height);
    let unit = 0;
    const tn = [...(await this.shaderSrc(name)).matchAll(/uniform\s+sampler2D\s+(t_\w+)/g)].map(m => m[1]);
    if (tn.length) { inputs = { ...inputs }; for (const n of tn) inputs[n] = await this.assetTex(n); }
    for (const [k, T] of Object.entries(inputs)) { gl.activeTexture(gl.TEXTURE0 + unit); gl.bindTexture(gl.TEXTURE_2D, T.t); gl.uniform1i(gl.getUniformLocation(p, k), unit); unit++; }
    for (const [k, v] of Object.entries(uni)) {
      const loc = gl.getUniformLocation(p, k); if (!loc) continue;
      if (typeof v === 'number') gl.uniform1f(loc, v); else if (v.length === 2) gl.uniform2fv(loc, v); else if (v.length === 3) gl.uniform3fv(loc, v); else if (v.length === 4) gl.uniform4fv(loc, v); else if (v.length === 9) gl.uniformMatrix3fv(loc, false, v);
    }
    gl.uniformMatrix3fv(gl.getUniformLocation(p, 'u_m'), false, m || [2,0,0, 0,2,0, -1,-1,1]);
    const a = gl.getAttribLocation(p, 'a_pos'); gl.bindBuffer(gl.ARRAY_BUFFER, this.quad); gl.enableVertexAttribArray(a); gl.vertexAttribPointer(a, 2, gl.FLOAT, false, 0, 0);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }
}

// Efektin ayar değerleri → uniform
function hexToRgb(h) { const n = parseInt(h.slice(1), 16); return [(n >> 16 & 255) / 255, (n >> 8 & 255) / 255, (n & 255) / 255]; }
function fxUniforms(meta, vals, box, s) {
  const u = {};
  for (const pr of meta.params || []) {
    if (pr.kind === 'color') { const h = vals[pr.k] ?? pr.def; u['c_' + pr.k] = hexToRgb(h); u['a_' + pr.k] = h.length === 9 ? parseInt(h.slice(7, 9), 16) / 255 : 1; }
    else if (pr.two) {
      let v = [vals[pr.k + 'X'] ?? pr.def, vals[pr.k + 'Y'] ?? (pr.defY ?? pr.def)];
      // Kutu yüzdesi (0..100, 50 = merkez) → merkezden px (katman birimi)
      if (pr.unit === 'box%' && box) v = [(v[0] / 100 - 0.5) * box[2] / s, (v[1] / 100 - 0.5) * box[3] / s];
      u['p_' + pr.k] = v;
    } else if (pr.three) u['p_' + pr.k] = [vals[pr.k + 'X'] ?? pr.def, vals[pr.k + 'Y'] ?? pr.defY, vals[pr.k + 'Z'] ?? pr.defZ];
    else if (pr.kind === 'gradient' || pr.kind === 'palette') {
      let st = vals[pr.k] ?? pr.def; if (typeof st === 'string') st = JSON.parse(st); const n = Math.min(32, st.length); u['p_' + pr.k + 'N'] = n;
      for (let i = 0; i < 32; i++) { const q = st[Math.min(i, n - 1)]; u['c_' + pr.k + i] = hexToRgb(q[0]); u['p_' + pr.k + 'P' + i] = (q[1] ?? 0) / 100; }
    } else if (typeof (vals[pr.k] ?? pr.def) === 'number') u['p_' + pr.k] = vals[pr.k] ?? pr.def;
  }
  return u;
}
function linearOf(spec, vals, meta, L) { if (!spec) return 0; if (spec.box) return spec.box * Math.max(L ? L.w : 0, L ? L.h : 0) + (spec.add || 0); if (spec.sum) return Math.max(0, spec.sum.reduce((a, k) => a + Math.max(0, vals[k] ?? (meta.params || []).find((p) => p.k === k)?.def ?? 0), 0) * (spec.mul ?? 1) + (spec.add || 0)); if (spec.max) return Math.max(0, ...spec.max.map((k) => vals[k] ?? (meta.params || []).find((p) => p.k === k)?.def ?? 0)); let v = spec.add || 0; if (spec.k) { const pr = (meta.params || []).find((p) => p.k === spec.k); v += (vals[spec.k] ?? pr?.def ?? 0) * (spec.mul ?? 1); } return Math.max(0, v); }

// Katmana efekt zincirini uygula: base (önceden çarpılmış doku, kutu + pad), sonuç doku
async function applyEffects(E, base, box, s, effects, t, dur, extra = {}) {
  let cur = base;
  for (const ef of effects) {
    const meta = E.meta[ef.type]; if (!meta || !['pixel', 'gen', 'repeat', '3d'].includes(meta.kind)) continue;
    const common = { u_res: [cur.w, cur.h], u_box: box, u_t: t, u_s: s, u_dur: dur, u_rot: window.CUR_ROT || 0, ...fxUniforms(meta, ef.v || {}, box, s) };
    const bufs = { src: cur }; const made = [];
    const passes = meta.passes || [{ fs: ef.type }];
    let last = cur;
    for (const ps of passes) {
      const inp = bufs[ps.in || (last === cur ? 'src' : '_last')] || last;
      if (ps.blur) { // ayrılabilir Gauss (iki geçiş)
        const sig = linearOf(ps.r, ef.v || {}, meta) * s;
        const a = E.tex(cur.w, cur.h), b = E.tex(cur.w, cur.h);
        await E.pass('_blur', a, { u_tex: bufs[ps.blur] || last, ...extra }, { ...common, u_dir: [1, 0], u_sigma: sig });
        await E.pass('_blur', b, { u_tex: a }, { ...common, u_dir: [0, 1], u_sigma: sig });
        E.free(a); made.push(b); bufs[ps.out || '_last'] = b; last = b; continue;
      }
      const out = E.tex(cur.w, cur.h); made.push(out); const ins = { u_tex: inp, u_src: cur, ...extra };
      for (const [k, v] of Object.entries(ps.aux || {})) ins[k] = bufs[v];
      await E.pass(ps.fs, out, ins, { ...common, ...(ps.set || {}) });
      bufs[ps.out || '_last'] = out; bufs._last = out; last = out;
    }
    // Ortak Karışım
    const mx = (ef.v || {})._mix;
    if (mx !== undefined && mx < 99.9) { const o = E.tex(cur.w, cur.h); made.push(o); await E.pass('_mix', o, { u_tex: last, u_src: cur }, { u_mix: mx / 100 }); last = o; }
    for (const m of made) if (m !== last) E.free(m);
    if (cur !== base && cur !== last) E.free(cur);
    cur = last;
  }
  return cur;
}
window.Engine = Engine; window.applyEffects = applyEffects; window.fxUniforms = fxUniforms; window.linearOf = linearOf;
