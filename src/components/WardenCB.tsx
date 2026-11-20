import { useEffect, useId, useState } from 'react';


/** 8 köşeli yıldız (dış yarıçap R, iç yarıçap r) */
function star8(cx: number, cy: number, R: number, r: number) {
  const pts: string[] = [];
  for (let i = 0; i < 16; i++) {
    const a = (Math.PI / 8) * i - Math.PI / 2;
    const rr = i % 2 ? r : R;
    pts.push(`${(cx + Math.cos(a) * rr).toFixed(1)},${(cy + Math.sin(a) * rr).toFixed(1)}`);
  }
  return pts.join(' ');
}

// ---------------------------------------------------------------------------------------------
/** Ushankanın tek rengi (ışık/gölge yok) */
export const HAT_COLOR = '#14214A';

// GÖVDE: bütün koordinatlar kullanıcının gönderdiği 736×736 referans çizimden piksel ölçüldü.
// ---------------------------------------------------------------------------------------------
const BODY = 'M322 330 C440 330 512 400 512 500 C512 572 492 616 452 634 C412 648 370 650 322 650 C274 650 232 648 192 634 C152 616 132 572 132 500 C132 400 204 330 322 330Z';
// Ushanka (referanstaki gibi): öne katlanmış uzun ön bant + iki yandan sarkan kulaklıklar
const HAT = 'M110 300 C196 286 398 272 500 266 C516 270 526 280 528 296 C532 336 532 384 526 420 C518 424 510 424 504 424 C462 406 398 398 322 400 C246 402 178 412 118 426 C111 382 107 342 110 300Z';
const FLAP_R = 'M512 266 C550 284 574 334 580 404 C586 474 578 562 584 612 C588 638 604 650 600 662 C568 668 520 658 486 664 C492 612 500 540 503 430 L516 424Z';
const FLAP_L = 'M126 410 C106 460 98 536 102 600 C104 634 116 652 138 654 C170 656 200 650 214 640 L204 420Z';

// ---------------------------------------------------------------------------------------------
// GÖZ PAKETİ: referanstaki göz kutuları (piksel): sol x 160–305 y 505–581, sağ x 333–490 y 507–578.
// Her ifade bu kutulardan türetilir. Gözler gövdeden ayrı katman: kayar, kırpılır, değişir.
// ---------------------------------------------------------------------------------------------
export interface EyeBox { l: number; r: number; top: number; bot: number }
export const EYE_L: EyeBox = { l: 140, r: 290, top: 500, bot: 586 };
export const EYE_R: EyeBox = { l: 312, r: 474, top: 503, bot: 583 };

// Göz türleri (göz paketi). lens: üstü düz/eğik kapaklı göz (varsayılan), round: tam açık,
// arc: mutlu (^), closed: kapalı (u), flat: düz çizgi, spiral: sersem, heart: aşık, star: heyecan, x: bitkin
export type EyeKind = 'lens' | 'round' | 'arc' | 'closed' | 'flat' | 'spiral' | 'heart' | 'star' | 'x';
export interface EyeSpec { kind: EyeKind; lid?: number; tilt?: number; scale?: number; pupil?: boolean }
type Brow = [number, number, number];
type Fx = 'motion' | 'tear' | 'tears' | 'sweat' | 'zzz' | 'hearts' | 'anger' | 'question' | 'exclam' | 'blush' | 'sparkle' | 'shake' | 'sigh' | 'music' | 'redface' | 'shiver';
export interface Pose { name: string; l: EyeSpec; r: EyeSpec; brows?: [Brow, Brow]; look?: [number, number]; tilt?: number; squash?: number; dy?: number; fx?: Fx[] }

const L = (lid = 0, tilt = 0): EyeSpec => ({ kind: 'lens', lid, tilt });
const K = (kind: EyeKind, scale = 1, pupil = false): EyeSpec => ({ kind, scale, pupil });

/** 30 duygu, 30 poz. Gözler + kaşlar + bakış + gövde duruşu + duygu işaretleri. Ağız yok. */
export const POSES = {
  idle:      { name: 'Normal', l: L(), r: L() },
  happy:     { name: 'Mutlu', l: K('arc'), r: K('arc'), fx: ['motion'], squash: 1.02 },
  joy:       { name: 'Neşeli', l: K('arc'), r: K('arc'), fx: ['sparkle', 'motion'], dy: -26, squash: 1.06 },
  laugh:     { name: 'Gülüyor', l: K('closed'), r: K('closed'), brows: [[-30, -40, -26], [-26, -40, -30]], fx: ['shake', 'tears'], tilt: -6 },
  wink:      { name: 'Göz kırpıyor', l: L(), r: K('arc'), brows: [[-16, -24, -18], [-34, -46, -36]], tilt: 4, fx: ['sparkle'] },
  think:     { name: 'Düşünceli', l: L(18), r: L(18), brows: [[-14, -24, -16], [-34, -52, -38]], look: [0.8, -0.6], tilt: 5 },
  wow:       { name: 'Şaşkın', l: K('round'), r: K('round'), brows: [[-30, -52, -32], [-32, -54, -34]], fx: ['exclam'] },
  shock:     { name: 'Şok', l: K('round', 1.05, true), r: K('round', 1.05, true), brows: [[-40, -60, -40], [-40, -60, -40]], dy: -30, squash: 1.1, fx: ['exclam', 'shiver'] },
  sad:       { name: 'Üzgün', l: L(6, 12), r: L(6, 12), brows: [[-10, -14, -32], [-32, -14, -10]], look: [0, 0.6], squash: 0.96 },
  cry:       { name: 'Ağlıyor', l: K('closed'), r: K('closed'), brows: [[-10, -16, -34], [-34, -16, -10]], fx: ['tears', 'shiver'], squash: 0.94 },
  angry:     { name: 'Kızgın', l: L(6, -14), r: L(6, -14), brows: [[-34, -26, -10], [-10, -26, -34]], fx: ['anger'] },
  furious:   { name: 'Öfkeli', l: L(14, -20), r: L(14, -20), brows: [[-40, -30, -6], [-6, -30, -40]], fx: ['anger', 'redface', 'shake'], squash: 0.95 },
  bored:     { name: 'Sıkılmış', l: L(30), r: L(30), look: [-0.6, 0], tilt: -4, fx: ['sigh'] },
  sleepy:    { name: 'Uykulu', l: L(42), r: L(42), brows: [[-12, -14, -12], [-12, -14, -12]], tilt: 7, fx: ['zzz'] },
  sleep:     { name: 'Uyuyor', l: K('flat'), r: K('flat'), tilt: 12, squash: 0.94, fx: ['zzz'] },
  shy:       { name: 'Utangaç', l: L(10), r: L(10), brows: [[-10, -18, -28], [-28, -18, -10]], look: [-0.7, 0.8], tilt: -8, fx: ['blush'] },
  love:      { name: 'Aşık', l: K('heart'), r: K('heart'), fx: ['hearts', 'blush'], tilt: 5 },
  excited:   { name: 'Heyecanlı', l: K('star'), r: K('star'), dy: -24, squash: 1.06, fx: ['sparkle', 'motion'] },
  confused:  { name: 'Kafası karışık', l: L(8, 6), r: K('round', 0.85), brows: [[-12, -18, -10], [-36, -58, -40]], tilt: 10, fx: ['question'] },
  suspicious:{ name: 'Şüpheli', l: L(30, -6), r: L(30, -6), brows: [[-22, -16, -10], [-10, -16, -22]], look: [-1, 0] },
  proud:     { name: 'Gururlu', l: K('closed'), r: K('closed'), brows: [[-30, -40, -30], [-30, -40, -30]], tilt: -6, dy: -8, fx: ['sparkle'] },
  scared:    { name: 'Korkmuş', l: K('round', 0.8, true), r: K('round', 0.8, true), brows: [[-20, -34, -44], [-44, -34, -20]], squash: 0.9, fx: ['sweat', 'shiver'] },
  worried:   { name: 'Endişeli', l: L(0, 8), r: L(0, 8), brows: [[-14, -22, -40], [-40, -22, -14]], look: [0.4, 0.3], fx: ['sweat'] },
  embarrassed:{ name: 'Mahcup', l: K('closed'), r: K('closed'), brows: [[-10, -16, -30], [-30, -16, -10]], tilt: -5, fx: ['blush', 'sweat'] },
  dizzy:     { name: 'Sersem', l: K('spiral'), r: K('spiral'), tilt: 9, fx: ['music'] },
  dead:      { name: 'Bitkin', l: K('x'), r: K('x'), tilt: -10, squash: 0.9, fx: ['sigh'] },
  smug:      { name: 'Kendini beğenmiş', l: L(26, -4), r: L(26, -4), brows: [[-16, -22, -18], [-36, -52, -40]], look: [0.8, 0], tilt: -5, fx: ['sparkle'] },
  curious:   { name: 'Meraklı', l: L(4), r: K('round', 1.05), brows: [[-14, -20, -16], [-34, -56, -38]], look: [0.6, -0.2], tilt: 8, fx: ['question'] },
  disappointed:{ name: 'Hayal kırıklığı', l: L(28, 6), r: L(28, 6), look: [0, 1], squash: 0.93, tilt: -3, fx: ['sigh'] },
  wave:      { name: 'Selam veriyor', l: K('arc'), r: L(), brows: [[-26, -36, -26], [-20, -30, -22]], tilt: -10, fx: ['motion', 'music'] },
  point:     { name: 'Gösteriyor', l: L(4), r: L(4), brows: [[-18, -26, -20], [-20, -28, -20]], look: [1, 0.2], tilt: 5, fx: ['motion'] },
} satisfies Record<string, Pose>;
export type Mood = keyof typeof POSES;

const brow = (e: EyeBox, [y1, ym, y2]: Brow) => `M${e.l + 14} ${e.top + y1} Q${(e.l + e.r) / 2} ${e.top + ym} ${e.r - 14} ${e.top + y2}`;
const EYE_FILL = { l: ['#FFFFFF', '#C9CDD3'], r: ['#3E63F0', '#1C3BB8'] } as const;
const INK = '#0B0B10';

function heartPath(cx: number, cy: number, r: number) {
  return `M${cx} ${cy + r * 0.9} C${cx - r * 1.4} ${cy - r * 0.1} ${cx - r * 0.7} ${cy - r * 1.2} ${cx} ${cy - r * 0.45} C${cx + r * 0.7} ${cy - r * 1.2} ${cx + r * 1.4} ${cy - r * 0.1} ${cx} ${cy + r * 0.9}Z`;
}

/** Tek bir göz (göz paketi) */
function Eye({ id, e, side, spec }: { id: string; e: EyeBox; side: 'l' | 'r'; spec: EyeSpec }) {
  const w = e.r - e.l, h = e.bot - e.top, cx = (e.l + e.r) / 2, cy = (e.top + e.bot) / 2;
  const line = (d: string) => <path d={d} fill="none" stroke={INK} strokeWidth="10" strokeLinecap="round" strokeLinejoin="round" />;
  switch (spec.kind) {
    case 'arc': return line(`M${e.l + 10} ${e.bot - 18} Q${cx} ${e.top - 12} ${e.r - 10} ${e.bot - 18}`);
    case 'closed': return line(`M${e.l + 6} ${cy - 4} Q${cx} ${e.bot + 6} ${e.r - 6} ${cy - 4}`);
    case 'flat': return line(`M${e.l + 14} ${cy + 10} L${e.r - 14} ${cy + 10}`);
    case 'x': { const r = h * 0.38; return line(`M${cx - r} ${cy - r} L${cx + r} ${cy + r} M${cx + r} ${cy - r} L${cx - r} ${cy + r}`); }
    case 'spiral': {
      let d = `M${cx} ${cy}`; const n = 70, R = h * 0.46;
      for (let i = 1; i <= n; i++) { const a = i / n * Math.PI * 5.2, r = R * i / n; d += ` L${(cx + Math.cos(a) * r * 1.25).toFixed(1)} ${(cy + Math.sin(a) * r).toFixed(1)}`; }
      return <path d={d} fill="none" stroke={INK} strokeWidth="7" strokeLinecap="round" />;
    }
    case 'heart': return <path d={heartPath(cx, cy + 2, h * 0.5)} fill="#E8333F" stroke={INK} strokeWidth="7" strokeLinejoin="round" />;
    case 'star': return <polygon points={star5(cx, cy + 2, h * 0.58, h * 0.26)} fill="#F2C230" stroke={INK} strokeWidth="7" strokeLinejoin="round" />;
  }
  let d: string;
  if (spec.kind === 'round') {
    const sc = spec.scale ?? 1, rx = w / 2 * sc, ry = (h / 2 + 10) * sc, yy = cy - 6;
    d = `M${cx - rx} ${yy} A${rx} ${ry} 0 1 0 ${cx + rx} ${yy} A${rx} ${ry} 0 1 0 ${cx - rx} ${yy}Z`;
  } else {
    // lens: üstü düz (gerekirse eğik) kapak, altı yuvarlak. tilt +: dış köşe aşağı (üzgün), -: iç köşe aşağı (kızgın)
    const top = e.top + (spec.lid ?? 0), t = spec.tilt ?? 0;
    const tl = top + (side === 'l' ? t : -t), tr = top + (side === 'l' ? -t : t);
    d = `M${e.l} ${tl} L${e.r} ${tr} C${e.r - w * 0.04} ${e.bot - 22} ${cx + w * 0.22} ${e.bot} ${cx} ${e.bot} C${cx - w * 0.22} ${e.bot} ${e.l + w * 0.04} ${e.bot - 22} ${e.l} ${tl}Z`;
  }
  const glintY = spec.kind === 'round' ? cy - h * 0.35 : e.top + (spec.lid ?? 0) + 18;
  return (
    <g>
      <path d={d} fill={`url(#${id}e${side})`} />
      {spec.pupil && <circle cx={cx} cy={cy} r={h * 0.16} fill={INK} />}
      {(spec.lid ?? 0) < 36 && <ellipse cx={cx - w * 0.18} cy={glintY} rx={w * 0.14} ry="7" fill="#FFFFFF" opacity=".55" />}
      <path d={d} fill="none" stroke={INK} strokeWidth="8" strokeLinejoin="round" />
    </g>
  );
}

/** 5 köşeli yıldız */
function star5(cx: number, cy: number, R: number, r: number) {
  const pts: string[] = [];
  for (let i = 0; i < 10; i++) { const a = Math.PI / 5 * i - Math.PI / 2, rr = i % 2 ? r : R; pts.push(`${(cx + Math.cos(a) * rr).toFixed(1)},${(cy + Math.sin(a) * rr).toFixed(1)}`); }
  return pts.join(' ');
}

/** Gözler: gövdeden ayrı katman. look: bakış, blink: kırpma */
function Eyes({ id, pose, look, lookY, blink, white }: { id: string; pose: Pose; look: number; lookY: number; blink: boolean; white?: boolean }) {
  const lineEyes = (s: EyeSpec) => s.kind !== 'lens' && s.kind !== 'round';
  const l = blink && !lineEyes(pose.l) ? K('closed') : pose.l;
  const r = blink && !lineEyes(pose.r) ? K('closed') : pose.r;
  return (
    <g className="wcb-eyes" style={{ transform: `translate(${look * 14}px, ${lookY * 8}px)`, transition: 'transform .3s ease-out' }}>
      <defs>
        {(['l', 'r'] as const).map((k) => (
          <linearGradient key={k} id={`${id}e${k}`} x1="0" y1="0" x2="0" y2="1"><stop offset="0" stopColor={EYE_FILL[white ? 'l' : k][0]} /><stop offset="1" stopColor={EYE_FILL[white ? 'l' : k][1]} /></linearGradient>
        ))}
      </defs>
      <Eye id={id} e={EYE_L} side="l" spec={l} />
      <Eye id={id} e={EYE_R} side="r" spec={r} />
      {pose.brows && (
        <g fill="none" stroke={INK} strokeWidth="8" strokeLinecap="round">
          <path d={brow(EYE_L, pose.brows[0])} /><path d={brow(EYE_R, pose.brows[1])} />
        </g>
      )}
    </g>
  );
}

/** Duygu işaretleri (gövdenin üstünde, dönmeden etkilenir) */
function Effects({ fx }: { fx: Fx[] }) {
  const has = (f: Fx) => fx.includes(f);
  const drop = (x: number, y: number, s = 1, fill = '#7CC8FF') => <path d={`M${x} ${y} Q${x + 16 * s} ${y + 26 * s} ${x + 12 * s} ${y + 36 * s} A${14 * s} ${14 * s} 0 1 1 ${x - 12 * s} ${y + 36 * s} Q${x - 16 * s} ${y + 26 * s} ${x} ${y}Z`} fill={fill} stroke={INK} strokeWidth="5" strokeLinejoin="round" />;
  const spark = (x: number, y: number, r: number) => <path d={`M${x} ${y - r} Q${x} ${y} ${x + r} ${y} Q${x} ${y} ${x} ${y + r} Q${x} ${y} ${x - r} ${y} Q${x} ${y} ${x} ${y - r}Z`} fill="#F2E230" stroke={INK} strokeWidth="4" strokeLinejoin="round" />;
  const txt = (t: string, x: number, y: number, fs: number, fill: string, rot = 0) => (
    <text x={x} y={y} fontSize={fs} fontWeight="900" fontFamily="Arial Black, Arial, sans-serif" fill={fill} stroke={INK} strokeWidth="6" paintOrder="stroke" transform={rot ? `rotate(${rot} ${x} ${y})` : undefined}>{t}</text>
  );
  return (
    <g className="wcb-fx">
      {has('blush') && <g fill="#FF6F91" opacity=".55"><ellipse cx="200" cy="612" rx="44" ry="16" /><ellipse cx="410" cy="610" rx="44" ry="16" /></g>}
      {has('redface') && <path d="M150 452 C160 420 220 412 322 412 C430 412 490 430 500 462 L500 520 L150 520Z" fill="#E8333F" opacity=".28" />}
      {has('tears') && <>{drop(170, 590, 0.9)}{drop(452, 588, 0.9)}<path d="M165 600 Q150 630 158 650" fill="none" stroke="#7CC8FF" strokeWidth="10" strokeLinecap="round" /><path d="M458 598 Q474 630 466 650" fill="none" stroke="#7CC8FF" strokeWidth="10" strokeLinecap="round" /></>}
      {has('tear') && drop(452, 588)}
      {has('sweat') && drop(528, 300, 1.2)}
      {has('anger') && <g transform="translate(530 300)" fill="none" stroke="#E8333F" strokeWidth="9" strokeLinecap="round"><path d="M-30 -8 Q-12 -8 -8 -30" /><path d="M8 -30 Q12 -8 30 -8" /><path d="M30 8 Q12 8 8 30" /><path d="M-8 30 Q-12 8 -30 8" /></g>}
      {has('question') && txt('?', 520, 316, 92, '#22D3E6', 12)}
      {has('exclam') && txt('!', 534, 316, 96, '#F2C230', 8)}
      {has('zzz') && <>{txt('z', 512, 336, 44, '#DCE9FF')}{txt('z', 544, 300, 56, '#DCE9FF')}{txt('Z', 574, 262, 70, '#DCE9FF')}</>}
      {has('hearts') && <><path d={heartPath(150, 300, 24)} fill="#E8333F" stroke={INK} strokeWidth="5" /><path d={heartPath(540, 280, 30)} fill="#E8333F" stroke={INK} strokeWidth="5" /><path d={heartPath(585, 340, 18)} fill="#FF6F91" stroke={INK} strokeWidth="5" /></>}
      {has('sparkle') && <>{spark(560, 300, 26)}{spark(120, 330, 18)}{spark(590, 380, 14)}</>}
      {has('music') && <g>{txt('♪', 540, 310, 70, '#22D3E6', -10)}{txt('♫', 110, 330, 54, '#3B9BFF', 8)}</g>}
      {has('sigh') && <g fill="#F7F8FA" stroke={INK} strokeWidth="4" opacity=".9"><circle cx="560" cy="560" r="16" /><circle cx="588" cy="532" r="11" /><circle cx="606" cy="510" r="7" /></g>}
      {(has('motion') || has('shake')) && (
        <g fill="none" stroke={INK} strokeWidth="5" strokeLinecap="round" opacity=".7">
          <path d="M100 480 Q90 506 100 532" /><path d="M110 492 Q105 506 110 520" />
          <path d="M598 440 Q608 466 598 492" /><path d="M588 452 Q593 466 588 480" />
          {has('shake') && <><path d="M86 560 Q76 586 86 612" /><path d="M612 520 Q622 546 612 572" /></>}
        </g>
      )}
      {has('shiver') && <g fill="none" stroke={INK} strokeWidth="4" strokeLinecap="round" opacity=".65"><path d="M96 430 l-10 8 l10 8 l-10 8" /><path d="M606 430 l10 8 l-10 8 l10 8" /></g>}
    </g>
  );
}

/**
 * WardenCB: Warden Motion'ın asistanı. Alttan basık yuvarlak gövde, kendi bayrağı (gövdeye kırpılı),
 * lacivert ushanka (turkuaz 8 köşeli yıldızlı), sol göz beyaz, sağ göz lacivert.
 * Ağzı yok: bütün duygu gözlerden, kaşlardan, duruştan ve duygu işaretlerinden. Kendiliğinden göz kırpar ve bakınır.
 */
/** Katmanlar (alttan üste): gölge, ushankanın arka kulağı, iç (bayrak), çizgi, göz, ushanka, işaretler. 'body' = arka kulak + iç + çizgi */
export type WcbLayer = 'shadow' | 'hatBack' | 'fill' | 'line' | 'body' | 'eyes' | 'hat' | 'fx';
export function WardenCB({ size = 120, mood = 'idle', look, lookY: lookYProp, autoBlink = true, layers, flagHref = 'wardencb/bayrak.png', flip = false, viewBox = '60 190 580 490', whiteEyes = false, still = false }: {
  size?: number; mood?: Mood; /** verilmezse kendiliğinden etrafa bakınır */ look?: number; lookY?: number; autoBlink?: boolean;
  /** Sadece bu katmanları çiz (pack parçaları için); verilmezse hepsi */ layers?: WcbLayer[];
  flagHref?: string;
  /** Aynala: diğer tarafa dönük */ flip?: boolean;
  viewBox?: string;
  /** İki göz de beyaz (pack'teki gözler) */ whiteEyes?: boolean;
  /** Duruş uygulanmaz (eğilme/ezilme yok) */ still?: boolean;
}) {
  const show = (k: WcbLayer) => !layers || layers.includes(k) || (['hatBack', 'fill', 'line'].includes(k) && layers.includes('body'));
  const id = useId().replace(/:/g, '');
  const pose: Pose = POSES[mood] ?? POSES.idle;
  const [blink, setBlink] = useState(false);
  const [wander, setWander] = useState({ x: 0, y: 0 });
  useEffect(() => {
    if (look !== undefined || pose.look || !autoBlink) return;
    let t: ReturnType<typeof setTimeout>;
    const loop = () => {
      t = setTimeout(() => {
        const r = Math.random();
        setWander(r < 0.35 ? { x: 0, y: 0 } : { x: Math.round((Math.random() * 2 - 1) * 10) / 10, y: Math.round((Math.random() * 1.4 - 0.6) * 10) / 10 });
        loop();
      }, 1400 + Math.random() * 2600);
    };
    loop();
    return () => clearTimeout(t);
  }, [look, autoBlink, mood]);
  useEffect(() => {
    if (!autoBlink) return;
    let t: ReturnType<typeof setTimeout>;
    const loop = () => {
      t = setTimeout(() => { setBlink(true); setTimeout(() => setBlink(false), 140); loop(); }, 2200 + Math.random() * 3200);
    };
    loop();
    return () => clearTimeout(t);
  }, [autoBlink]);
  const lx = look ?? pose.look?.[0] ?? wander.x;
  const ly = lookYProp ?? pose.look?.[1] ?? (look !== undefined ? 0 : wander.y);
  const sq = still ? 1 : pose.squash ?? 1, tilt = still ? 0 : pose.tilt ?? 0, dy = still ? 0 : pose.dy ?? 0;
  // Duruş: alt orta noktadan ezilme/uzama, merkezden eğilme, zıplama
  const bodyT = `translate(0 ${dy}) rotate(${tilt} 330 520) translate(330 650) scale(${(2 - sq).toFixed(3)} ${sq.toFixed(3)}) translate(-330 -650)`;
  return (
    <svg width={size} height={size * +viewBox.split(' ')[3] / +viewBox.split(' ')[2]} viewBox={viewBox} role="img" aria-label={`WardenCB: ${pose.name}`} style={flip ? { transform: 'scaleX(-1)' } : undefined}>
      <defs>
        <clipPath id={`${id}b`}><path d={BODY} /></clipPath>
      </defs>
      {show('shadow') && <ellipse cx="340" cy="664" rx={230 * (dy < 0 ? 0.8 : 1)} ry="12" fill="#0B1430" opacity={dy < 0 ? 0.14 : 0.22} />}
      <g className="wcb-pose" transform={bodyT}>
        {/* ---- GÖVDE katmanı ---- */}
        {show('hatBack') && <path className="wcb-hatback" d={FLAP_L} fill={HAT_COLOR} stroke={INK} strokeWidth="8" strokeLinejoin="round" />}
        {show('fill') && <g className="wcb-fill" clipPath={`url(#${id}b)`}>
          <rect x="120" y="320" width="400" height="340" fill="#F7F8FA" />
          {flagHref && <image href={flagHref} x="112" y="400" width="390" height="260" preserveAspectRatio="none" />}
        </g>}
        {show('line') && <path className="wcb-line" d={BODY} fill="none" stroke={INK} strokeWidth="8" strokeLinejoin="round" />}
        {/* ---- GÖZ katmanı (ayrı) ---- */}
        {show('eyes') && <Eyes id={id} pose={pose} look={lx} lookY={ly} blink={blink} white={whiteEyes} />}
        {/* ---- ŞAPKA katmanı ---- */}
        {show('hat') && <g className="wcb-hat">
          <path d={FLAP_R} fill={HAT_COLOR} stroke={INK} strokeWidth="8" strokeLinejoin="round" />
          <path d={HAT} fill={HAT_COLOR} stroke={INK} strokeWidth="8" strokeLinejoin="round" />
          <path d="M526 420 C544 414 562 407 579 398" fill="none" stroke={INK} strokeWidth="8" strokeLinecap="round" />
          <polygon points={star8(310, 346, 40, 19)} fill="#1E2A2E" stroke="#22D3E6" strokeWidth="7" strokeLinejoin="round" />
        </g>}
      </g>
      {/* ---- Duygu işaretleri ---- */}
      {show('fx') && <g transform={`translate(0 ${dy})`}><Effects fx={pose.fx ?? []} /></g>}
    </svg>
  );
}
