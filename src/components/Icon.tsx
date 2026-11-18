const P: Record<string, string> = {
  menu: 'M4 6h16M4 12h16M4 18h16',
  plus: 'M12 5v14M5 12h14',
  close: 'M6 6l12 12M18 6L6 18',
  back: 'M19 12H5M11 6l-6 6 6 6',
  exit: 'M14 4h5v16h-5M3 12h11M7 8l-4 4 4 4',
  chevR: 'M9 6l6 6-6 6',
  chevD: 'M6 9l6 6 6-6',
  gear: 'M12 2l2 3 3.5-.5.9 3.4 3.1 1.6-1.4 3.2 1.4 3.2-3.1 1.6-.9 3.4L14 19l-2 3-2-3-3.5.5-.9-3.4-3.1-1.6 1.4-3.2-1.4-3.2 3.1-1.6.9-3.4L10 5zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z',
  export: 'M20 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h5M14 4h6v6M20 4l-9 9',
  undo: 'M9 14L4 9l5-5M4 9h11a5 5 0 0 1 0 10h-3',
  redo: 'M15 14l5-5-5-5M20 9H9a5 5 0 0 0 0 10h3',
  toStart: 'M5 5v14M20 12H9M13 8l-4 4 4 4',
  toEnd: 'M19 5v14M4 12h11M11 8l4 4-4 4',
  copy: 'M9 4h11v11H9zM6 9H4v11h11v-2',
  trash: 'M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13',
  more: 'M5 12h.01M12 12h.01M19 12h.01',
  home: 'M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z',
  cap: 'M2 9l10-5 10 5-10 5zM6 11v5c3 2 9 2 12 0v-5',
  film: 'M5 3h15v15H5zM3 7v12a2 2 0 0 0 2 2h12M11 8l4 2.5-4 2.5z',
  grid: 'M3 3h18v18H3zM3 9h18M10 21V9',
  move: 'M12 3v18M3 12h18M9 6l3-3 3 3M9 18l3 3 3-3M6 9l-3 3 3 3M18 9l3 3-3 3',
  rotate: 'M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7',
  scale: 'M4 10h10v10H4zM14 4h6v6M20 4l-8 8',
  bucket: 'M5 11l7-7 7 7-7 7zM19 15s2 2.5 2 4a2 2 0 0 1-4 0c0-1.5 2-4 2-4z',
  opacity: 'M12 3a9 9 0 1 0 0 18zM12 3a9 9 0 0 1 0 18',
  sparkle: 'M12 3l2 6 6 2-6 2-2 6-2-6-6-2 6-2z',
  ball: 'M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM8.5 10.5v1M15.5 10.5v1',
  text: 'M5 6h14M12 6v13',
  image: 'M3 5h18v14H3zM8 11a2 2 0 1 0 0-4 2 2 0 0 0 0 4zM21 16l-5-5-9 8',
  flag: 'M5 21V4M5 4h12l-2 4 2 4H5',
  shapes: 'M7 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM14 3l4 7h-8zM3 14h7v7H3zM17.5 21s-4-2.5-4-5a2 2 0 0 1 4-1 2 2 0 0 1 4 1c0 2.5-4 5-4 5z',
  folder: 'M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
  upload: 'M12 16V4M7 9l5-5 5 5M4 16v3a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-3',
  search: 'M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM20 20l-4-4',
  star: 'M12 3l2.8 5.8 6.2.9-4.5 4.4 1 6.2L12 17.4 6.5 20.3l1-6.2L3 9.7l6.2-.9z',
  trimL: 'M10 4v16M14 8l-4 4 4 4M20 8v8',
  trimR: 'M14 4v16M10 8l4 4-4 4M4 8v8',
  split: 'M12 3v18M8 8l-4 4 4 4M16 8l4 4-4 4',
  eye: 'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6z',
  eyeOff: 'M3 3l18 18M10.6 6.1A10 10 0 0 1 12 6c6 0 10 6 10 6a17 17 0 0 1-3.2 3.7M6.6 6.6C3.8 8.4 2 12 2 12s4 7 10 7c1.6 0 3-.4 4.3-1',
  check: 'M5 12l5 5 9-10',
  fit: 'M4 8V4h4M16 4h4v4M20 16v4h-4M8 20H4v-4',
  key: 'M12 3l9 9-9 9-9-9z',
  border: 'M4 4h16v16H4zM8 8h8v8H8z',
  loop: 'M17 2l4 4-4 4M3 11V9a3 3 0 0 1 3-3h15M7 22l-4-4 4-4M21 13v2a3 3 0 0 1-3 3H3',
  pen: 'M4 20l4-1 11-11-3-3L5 16z',
  layers: 'M12 3l9 5-9 5-9-5zM3 13l9 5 9-5',
};

export function Icon({ name, size = 22, fill = false, stroke = 1.8 }: { name: keyof typeof P | string; size?: number; fill?: boolean; stroke?: number }) {
  if (name === 'play') return <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M7 4.5l13 7.5-13 7.5z" /></svg>;
  if (name === 'pause') return <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><rect x="6" y="4.5" width="4" height="15" rx="1" /><rect x="14" y="4.5" width="4" height="15" rx="1" /></svg>;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill={fill ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth={stroke} strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d={P[name] ?? ''} />
    </svg>
  );
}
