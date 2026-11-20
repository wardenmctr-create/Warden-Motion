import { useEffect, useId, useState } from 'react';

export type Mood = 'idle' | 'happy' | 'point' | 'think' | 'wave' | 'wow' | 'sad' | 'angry' | 'wink';

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
// GÖVDE: bütün koordinatlar kullanıcının gönderdiği 736×736 referans çizimden piksel ölçüldü.
// ---------------------------------------------------------------------------------------------
const BODY = 'M322 330 C440 330 512 400 512 500 C512 572 492 616 452 634 C412 648 370 650 322 650 C274 650 232 648 192 634 C152 616 132 572 132 500 C132 400 204 330 322 330Z';
// Ushanka (referanstaki gibi): öne katlanmış uzun ön bant + iki yandan sarkan kulaklıklar
const HAT = 'M120 302 C200 288 400 272 512 264 C517 302 519 362 516 424 C470 406 400 398 322 400 C240 402 180 412 128 426 C121 382 117 342 120 302Z';
const HAT_TOP = 'M120 302 C200 288 400 272 512 264 L513 284 C400 292 200 308 121 322Z';
const FLAP_R = 'M512 266 C550 284 574 334 580 404 C586 474 578 562 584 612 C588 638 604 650 600 662 C568 668 520 658 486 664 C492 612 500 540 503 430 L516 424Z';
const FLAP_L = 'M126 410 C106 460 98 536 102 600 C104 634 116 652 138 654 C170 656 200 650 214 640 L204 420Z';

// ---------------------------------------------------------------------------------------------
// GÖZ PAKETİ: referanstaki göz kutuları (piksel): sol x 160–305 y 505–581, sağ x 333–490 y 507–578.
// Her ifade bu kutulardan türetilir. Gözler gövdeden ayrı katman: kayar, kırpılır, değişir.
// ---------------------------------------------------------------------------------------------
export interface EyeBox { l: number; r: number; top: number; bot: number }
export const EYE_L: EyeBox = { l: 160, r: 310, top: 500, bot: 586 };
export const EYE_R: EyeBox = { l: 332, r: 494, top: 503, bot: 583 };

type EyeShape = { d: string; line?: boolean };
/** Göz şekli: kapak açısı (derece; + dışa doğru aşağı), kapak düşüşü (px), şekil türü */
function eyeShape(e: EyeBox, side: 'l' | 'r', kind: Mood | 'closed'): EyeShape {
  const w = e.r - e.l, cx = (e.l + e.r) / 2, mid = (e.top + e.bot) / 2;
  const lens = (top: number, tilt = 0) => {
    // Üstü düz (gerekirse eğik) kapak, altı yuvarlak
    const tl = top + (side === 'l' ? tilt : -tilt), tr = top + (side === 'l' ? -tilt : tilt);
    return `M${e.l} ${tl} L${e.r} ${tr} C${e.r - w * 0.04} ${e.bot - 22} ${cx + w * 0.22} ${e.bot} ${cx} ${e.bot} C${cx - w * 0.22} ${e.bot} ${e.l + w * 0.04} ${e.bot - 22} ${e.l} ${tl}Z`;
  };
  switch (kind) {
    case 'happy': case 'wave': return { line: true, d: `M${e.l + 8} ${e.bot - 20} Q${cx} ${e.top - 10} ${e.r - 8} ${e.bot - 20}` };
    case 'closed': return { line: true, d: `M${e.l + 4} ${e.bot - 14} Q${cx} ${e.bot + 2} ${e.r - 4} ${e.bot - 14}` };
    case 'wink': return side === 'r' ? { line: true, d: `M${e.l + 8} ${e.bot - 20} Q${cx} ${e.top - 10} ${e.r - 8} ${e.bot - 20}` } : { d: lens(e.top) };
    case 'wow': { const t = e.top - 18; return { d: `M${e.l} ${(t + e.bot) / 2} C${e.l} ${t} ${e.r} ${t} ${e.r} ${(t + e.bot) / 2} C${e.r} ${e.bot} ${e.l} ${e.bot} ${e.l} ${(t + e.bot) / 2}Z` }; }
    case 'think': return { d: lens(e.top + 18) };
    case 'sad': return { d: lens(e.top + 6, 12) };
    case 'angry': return { d: lens(e.top + 6, -14) };
    default: return { d: lens(e.top) };
  }
  void mid;
}

/** İnce kaşlar (sol, sağ): sadece gerektiği ifadelerde */
const brow = (e: EyeBox, y1: number, ym: number, y2: number) => `M${e.l + 14} ${e.top + y1} Q${(e.l + e.r) / 2} ${e.top + ym} ${e.r - 14} ${e.top + y2}`;
const BROWS: Partial<Record<Mood, [string, string]>> = {
  think: [brow(EYE_L, -14, -24, -16), brow(EYE_R, -34, -52, -38)],
  wow: [brow(EYE_L, -30, -52, -32), brow(EYE_R, -32, -54, -34)],
  sad: [brow(EYE_L, -10, -14, -32), brow(EYE_R, -32, -14, -10)],
  angry: [brow(EYE_L, -34, -26, -10), brow(EYE_R, -10, -26, -34)],
};

const EYE_FILL = { l: ['#FFFFFF', '#C9CDD3'], r: ['#3E63F0', '#1C3BB8'] } as const;

/** Gözler: gövdeden ayrı katman. look: -1..1 bakış, blink: kırpma */
function Eyes({ id, mood, look, lookY, blink }: { id: string; mood: Mood; look: number; lookY: number; blink: boolean }) {
  const kind: Mood | 'closed' = blink ? 'closed' : mood;
  const one = (e: EyeBox, side: 'l' | 'r') => {
    const sh = eyeShape(e, side, kind);
    const w = e.r - e.l;
    if (sh.line) return <path key={side} d={sh.d} fill="none" stroke="#0B0B10" strokeWidth="10" strokeLinecap="round" />;
    return (
      <g key={side}>
        <path d={sh.d} fill={`url(#${id}e${side})`} />
        <ellipse cx={(e.l + e.r) / 2 - w * 0.18} cy={e.top + (kind === 'think' ? 34 : kind === 'wow' ? 4 : 20)} rx={w * 0.16} ry="8" fill="#FFFFFF" opacity=".55" />
        <path d={sh.d} fill="none" stroke="#0B0B10" strokeWidth="8" strokeLinejoin="round" />
      </g>
    );
  };
  return (
    <g className="wcb-eyes" style={{ transform: `translate(${look * 14}px, ${lookY * 8}px)`, transition: 'transform .3s ease-out' }}>
      <defs>
        {(['l', 'r'] as const).map((k) => (
          <linearGradient key={k} id={`${id}e${k}`} x1="0" y1="0" x2="0" y2="1"><stop offset="0" stopColor={EYE_FILL[k][0]} /><stop offset="1" stopColor={EYE_FILL[k][1]} /></linearGradient>
        ))}
      </defs>
      {one(EYE_L, 'l')}
      {one(EYE_R, 'r')}
      {BROWS[mood] && !blink && (
        <g fill="none" stroke="#0B0B10" strokeWidth="6" strokeLinecap="round">
          <path d={BROWS[mood]![0]} /><path d={BROWS[mood]![1]} />
        </g>
      )}
    </g>
  );
}

/**
 * WardenCB: Warden Motion'ın asistanı. Alttan basık yuvarlak gövde, kendi bayrağı (gövdeye kırpılı),
 * zeytin yeşilinden laciverte geçen ushanka (turkuaz 8 köşeli yıldızlı), sol göz beyaz, sağ göz lacivert.
 * Ağzı yok: bütün duygu gözlerden ve gerektiğinde ince kaşlardan. Arada bir kendiliğinden göz kırpar.
 */
export function WardenCB({ size = 120, mood = 'idle', look, autoBlink = true }: { size?: number; mood?: Mood; /** verilmezse kendiliğinden etrafa bakınır */ look?: number; autoBlink?: boolean }) {
  const id = useId().replace(/:/g, '');
  const [blink, setBlink] = useState(false);
  const [wander, setWander] = useState({ x: 0, y: 0 });
  useEffect(() => {
    if (look !== undefined || !autoBlink) return;
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
  }, [look, autoBlink]);
  const lx = look ?? wander.x, ly = look !== undefined ? 0 : wander.y;
  useEffect(() => {
    if (!autoBlink) return;
    let t: ReturnType<typeof setTimeout>;
    const loop = () => {
      t = setTimeout(() => { setBlink(true); setTimeout(() => setBlink(false), 140); loop(); }, 2200 + Math.random() * 3200);
    };
    loop();
    return () => clearTimeout(t);
  }, [autoBlink]);
  return (
    <svg width={size} height={size * 452 / 534} viewBox="86 220 534 452" role="img" aria-label="WardenCB">
      <defs>
        <clipPath id={`${id}b`}><path d={BODY} /></clipPath>
        <linearGradient id={`${id}u`} x1="0" y1="0" x2="1" y2="0">
          <stop offset="0" stopColor="#5C5A22" /><stop offset=".45" stopColor="#323A2E" /><stop offset=".7" stopColor="#1A2540" /><stop offset="1" stopColor="#14214A" />
        </linearGradient>
        <linearGradient id={`${id}fl`} x1="0" y1="0" x2="1" y2="0"><stop offset="0" stopColor="#4A4A1A" /><stop offset="1" stopColor="#6A6A2A" /></linearGradient>
        <linearGradient id={`${id}f`} x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#1C2C5C" /><stop offset="1" stopColor="#0F1838" /></linearGradient>
        <radialGradient id={`${id}s`} cx=".35" cy=".35" r=".9">
          <stop offset="0" stopColor="#FFFFFF" stopOpacity=".25" /><stop offset=".5" stopColor="#FFFFFF" stopOpacity="0" /><stop offset="1" stopColor="#000000" stopOpacity=".35" />
        </radialGradient>
      </defs>
      <ellipse cx="350" cy="660" rx="230" ry="12" fill="#0B1430" opacity=".22" />
      {/* ---- GÖVDE katmanı ---- */}
      <g className="wcb-body">
        {/* Sol kulaklık yanağın arkasında */}
        <path d={FLAP_L} fill={`url(#${id}fl)`} stroke="#0B0B10" strokeWidth="8" strokeLinejoin="round" />
        <path d={FLAP_R} fill="#14214A" stroke="#0B0B10" strokeWidth="8" strokeLinejoin="round" />
        <g clipPath={`url(#${id}b)`}>
          <rect x="120" y="320" width="400" height="340" fill="#F7F8FA" />
          <image href="wardencb/bayrak.png" x="112" y="400" width="390" height="260" preserveAspectRatio="none" />
          <rect x="120" y="320" width="400" height="340" fill={`url(#${id}s)`} />
        </g>
        <path d={BODY} fill="none" stroke="#0B0B10" strokeWidth="8" strokeLinejoin="round" />
      </g>
      {/* ---- GÖZ katmanı (ayrı) ---- */}
      <Eyes id={id} mood={mood} look={lx} lookY={ly} blink={blink} />
      {/* ---- ŞAPKA katmanı ---- */}
      <g className="wcb-hat">
        <path d={FLAP_R} fill={`url(#${id}f)`} stroke="#0B0B10" strokeWidth="8" strokeLinejoin="round" />
        <path d="M540 470 C548 520 546 580 552 626" fill="none" stroke="#000" strokeOpacity=".28" strokeWidth="6" strokeLinecap="round" />
        <path d={HAT} fill={`url(#${id}u)`} stroke="#0B0B10" strokeWidth="8" strokeLinejoin="round" />
        <path d={HAT_TOP} fill="#FFFFFF" opacity=".08" />
        <path d="M138 410 C200 396 300 386 400 386 C450 386 488 392 506 400" fill="none" stroke="#000" strokeOpacity=".25" strokeWidth="6" strokeLinecap="round" />
        <polygon points={star8(300, 348, 40, 19)} fill="#1E2A2E" stroke="#22D3E6" strokeWidth="7" strokeLinejoin="round" />
      </g>
      {mood !== 'idle' && (
        <g fill="none" stroke="#0B0B10" strokeWidth="4" strokeLinecap="round" opacity=".7">
          <path d="M104 500 Q96 520 104 540" /><path d="M112 510 Q108 520 112 530" />
          <path d="M540 500 Q548 520 540 540" /><path d="M532 510 Q536 520 532 530" />
          <path d="M260 252 Q300 244 340 250" /><path d="M590 340 Q598 360 590 380" />
        </g>
      )}
    </svg>
  );
}
