// Rehbere göre yazılmış (ready) efektlerin önizleme sahneleri.
// SC2[tür] = { subj, w, h, bg, v(p,t) } ya da hiç yoksa AUTO: kategoriye uygun konu + Animasyonlu/Güçlü hazır ayar.
const SC2 = {};
const PHOTOS = ['kapadokya', 'istanbul', 'cay', 'laleler', 'aycicek', 'nar', 'denizalti', 'uzay', 'gece', 'dag'];
const CBS = [['tr', 'mutlu', 'fes'], ['jp', 'normal', 'tac'], ['br', 'saskin'], ['de', 'kizgin', 'silindir'], ['az', 'mutlu'], ['kr', 'normal', 'kep'], ['it', 'mutlu', 'kep']];
function hashStr(s) { let h = 7; for (const c of s) h = (h * 31 + c.charCodeAt(0)) >>> 0; return h; }
function presetFn(meta, code) {
  const pr = (meta.presets || []).find((x) => x.code === code); if (!pr) return null;
  return (p, t) => {
    const v = { ...(pr.vals || {}), ...(pr.cols || {}) };
    for (const [k, ks] of Object.entries(pr.keys || {})) {
      // önizleme döngüsü: 0→1 sn yerine tüm süreye yay (git-gel)
      const q = 0.5 - 0.5 * Math.cos(p * Math.PI * 2); const a = ks[0][1], b = ks[Math.floor(ks.length / 2)][1]; v[k] = a + (b - a) * q;
    }
    return v;
  };
}
function autoScene(type) {
  const m = E.meta[type]; const h = hashStr(type);
  const sc = SC2[type] || {};
  let draw, w = 240, hh = 240, bg = bgNavy;
  const subj = sc.subj || (m.cat === 16 || m.cat === 5 || m.cat === 6 ? 'cb' : m.cat === 10 ? 'word' : 'photo');
  if (typeof subj === 'function') { draw = subj; w = sc.w || 200; hh = sc.h || 200; bg = sc.bg || dark('#E3EEFC'); }
  else if (subj === 'cb') { const c = CBS[h % CBS.length]; draw = SUBJ.cb(...c); w = sc.w || 160; hh = sc.h || 160; bg = sc.bg || dark('#E3EEFC'); }
  else if (subj === 'word') { draw = SUBJ.word(sc.text || 'MERHABA', 46, '#F7F8FA'); w = 230; hh = 90; }
  else if (subj === 'wcb') { draw = SUBJ.wcbPose(sc.pose || 'mutlu'); w = 200; hh = 200; bg = sc.bg || dark('#E3EEFC'); }
  else { draw = SUBJ[sc.photo || PHOTOS[h % PHOTOS.length]]; }
  const v = sc.v || presetFn(m, 'AN') || presetFn(m, 'GÇ') || (() => ({}));
  return { size: 240, dur: 2, fps: 12, bg: sc.bg || bg, layers: [...(sc.under || []), { x: 120, y: 120, w: sc.w || w, h: sc.h || hh, draw, fx: [{ type, v }], tr: sc.tr }] };
}
window.SC2 = SC2; window.autoScene = autoScene;
// Denetim: shader derleniyor mu, görüntüyü değiştiriyor mu?
window.probe = async function (type) {
  const m = E.meta[type]; const g = presetFn(m, 'GÇ') || presetFn(m, 'AN') || presetFn(m, 'DN');
  const sc = autoScene(type); sc.layers[sc.layers.length - 1].fx[0].v = g || (() => ({}));
  const a = await frame(sc, 0.3);
  const sc0 = { ...sc, layers: sc.layers.map((L) => ({ ...L, fx: [] })) };
  const b = await frame(sc0, 0.3);
  return { same: a === b, blank: a.length < 3000 };
};
SC2.cutback = { subj: 'cb', w: 140, h: 140, v: (p) => ({ malzRenk: ['#C9A57A', '#F4F1EA', '#E30A17', '#2F7BF6'][Math.floor(p * 3.999)] }) };
SC2.cardpuppet = { subj: 'cb', w: 140, h: 140, v: () => ({}), tr: (p) => ({ rot: Math.sin(p * Math.PI * 2) * 8 }) };
SC2.texturize = { photo: 'istanbul', v: (p) => ({ dokuTuru: Math.floor(p * 5.999) * 2 % 13, dokuGucu: 85, kabartma: 6 }) };
