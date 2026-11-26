# Kullanıcının "430 Efekt Ayar ve Panel Rehberi"ni (Markdown) okuyup her efektin ayar listesini çıkarır.
# Kullanım: python3 spec.py <rehber.md>  → spec.json (catalog.py bunu kullanır)
import re, json, sys, os, unicodedata

TR = str.maketrans("çğıöşüÇĞİÖŞÜâîû", "cgiosuCGIOSUaiu")
def slug(s):
    s = s.translate(TR).lower()
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()
    w = re.findall(r"[a-z0-9]+", s)
    if not w: return "p"
    k = w[0][:8] + "".join(x[:4].capitalize() for x in w[1:3])
    return ("p" + k) if k[0].isdigit() else k

def num(s):
    s = s.replace("−", "-").replace(",", ".").strip()
    m = re.search(r"-?\d+(?:\.\d+)?(?:e\d+)?", s)
    return float(m.group()) if m else None

UNIT = [("Hz", "Hz"), ("dB", "dB"), ("px", "px"), ("°", "°"), ("%", "%"), (" s", "s"), ("ms", "ms"), ("x", "×"), ("st", "st"), ("cent", "cent")]
def unit_of(*ss):
    for s in ss:
        s = s.strip()
        for a, u in UNIT:
            if s.endswith(a.strip()) and (a != " s" or re.search(r"\d\s*s$", s)): return u
    return ""

def rng(s):
    s = s.replace("−", "-")
    m = re.search(r"(-?\d+(?:[.,]\d+)?)\s*…\s*(-?\d+(?:[.,]\d+)?)", s)
    if m: return num(m.group(1)), num(m.group(2))
    return None

AKM = {"Evet": "yes", "Adımlı": "step", "Hayır": "no"}
def step_for(u, mn, mx, integer):
    if integer: return 1
    return {"%": 0.1, "px": 0.1, "°": 0.1, "Hz": 0.01, "s": 0.01, "dB": 0.1}.get(u, 0.01)

def param(row, used):
    lab, kind, dv, rg, ak = row
    k = slug(lab); base = k; i = 2
    while k in used: k = f"{base}{i}"; i += 1
    used.add(k)
    p = dict(k=k, l=lab, anim=AKM.get(ak, "yes"))
    if kind in ("Cetvel", "Tam sayı cetveli", "Tam sayı / yeniden üret"):
        r = rng(rg) or (0, 100); u = unit_of(dv, rg); integer = kind != "Cetvel"
        d = num(dv); d = r[0] if d is None else d
        st = step_for(u, *r, integer)
        p.update(kind="jog", min=r[0], max=r[1], def_=d, step=st, jog=st, unit=u)
        if kind == "Tam sayı / yeniden üret": p["reseed"] = True
        if integer: p["int"] = True
    elif kind == "Anahtar":
        p.update(kind="toggle", min=0, max=1, def_=1 if dv.startswith("Açık") else 0, step=1, jog=1)
    elif kind == "Seçim":
        opts = [o.strip() for o in rg.split(" / ")]
        d = opts.index(dv) if dv in opts else 0
        p.update(kind="choice", min=0, max=len(opts) - 1, def_=d, step=1, jog=1, opts=opts)
    elif kind in ("Renk seçici",):
        h = re.search(r"#[0-9A-Fa-f]{6,8}", dv)
        p.update(kind="color", min=0, max=0, def_=(h.group().upper() if h else "#FFFFFF"), step=1, jog=1)
    elif kind in ("X/Y nokta + tuval", "X/Y cetvel + tuval", "X/Y sayısal cetvel"):
        m = re.search(r"X\s*(-?[\d.,]+);\s*Y\s*(-?[\d.,]+)", dv.replace("−", "-"))
        x, y = (num(m.group(1)), num(m.group(2))) if m else (0, 0)
        r = rng(rg) or (-4000, 4000)
        u = "box%" if kind == "X/Y nokta + tuval" else unit_of(dv, rg)
        st = 0.1 if u in ("box%", "px") else 0.01
        p.update(kind="jog", two=True, min=r[0], max=r[1], def_=x, defY=y, step=st, jog=st, unit=u)
    elif kind == "3 eksen cetvel":
        vals = [num(v) for v in re.split(r",", dv.replace("−", "-"))]
        vals = [v if v is not None else 0 for v in vals] + [0, 0, 0]
        r = rng(rg) or (-360, 360)
        u = unit_of(dv, rg)
        p.update(kind="jog", three=True, min=r[0], max=r[1], def_=vals[0], defY=vals[1], defZ=vals[2], step=0.1, jog=0.1, unit=u)
    elif kind in ("Geçiş / palet düzenleyici", "Palet düzenleyici"):
        stops = []
        for part in dv.split(" / "):
            h = re.search(r"#[0-9A-Fa-f]{6}", part); a = re.search(r"@(\d+)", part)
            if h: stops.append([h.group().upper(), float(a.group(1)) if a else None])
        n = len(stops)
        for i2, s in enumerate(stops):
            if s[1] is None: s[1] = 0 if n == 1 else round(100 * i2 / (n - 1), 1)
        p.update(kind="gradient" if kind.startswith("Geçiş") else "palette", min=0, max=0, def_=stops, step=1, jog=1)
    elif kind == "Eğri düzenleyici":
        p.update(kind="curve", min=0, max=1, def_=[[0, 0], [1, 1]], step=1, jog=1, hint=dv)
    elif kind in ("Kaynak seçici", "Katman seçici"):
        p.update(kind="source", min=0, max=0, def_="", step=1, jog=1, multi=kind == "Katman seçici", hint=rg)
    elif kind == "Metin alanı":
        p.update(kind="text", min=0, max=0, def_="" if dv == "(boş)" else dv, step=1, jog=1)
    elif kind == "Zaman seçici":
        p.update(kind="jog", min=0, max=1e5, def_=0, step=0.01, jog=0.01, unit="s")
    elif kind == "Gösterge":
        p.update(kind="info", min=0, max=0, def_=0, step=1, jog=1, hint=lab)
    elif kind == "Komut":
        p.update(kind="button", min=0, max=0, def_=0, step=1, jog=1)
    else:  # Tuval/çoklu değer, renk çarkı, HSL aralığı, tuval dikdörtgeni: özel düzenleyiciler
        p.update(kind="editor", min=0, max=0, def_=dv, step=1, jog=1, hint=kind, opts=[rg])
    p["src"] = kind
    return p

def parse(path):
    t = open(path, encoding="utf-8").read()
    out = {}
    common3d = []
    for b0 in re.split(r"\n### ", t)[1:]:
        cut = re.split(r"\n## ", b0, maxsplit=1)
        b = cut[0]
        if len(cut) > 1 and "Ortak 3B grubu" in cut[1]:
            common3d = [[x.strip() for x in r.strip().strip("|").split("|")] for r in cut[1].split("\n")
                        if r.startswith("|") and not r.startswith("|---") and not r.startswith("| Özellik")]
        m = re.match(r"(\d+)\. \*\*(.+?)\*\* \((.+?)\):\s*(.*)", b)
        if not m: continue
        n, name, en, desc = int(m.group(1)), m.group(2), m.group(3), m.group(4).strip()
        rows = [[x.strip() for x in r.strip().strip("|").split("|")] for r in b.split("\n")
                if r.startswith("|") and not r.startswith("|---") and not r.startswith("| Özellik")]
        used = {"mix"}
        ps = [param(r, used) for r in rows if len(r) == 5]
        notes = []
        pres = None; teach = None
        for line in b.split("\n"):
            line = line.strip()
            if line.startswith("- **Hazır ayarlar:**"): pres = line.split(":**", 1)[1].strip()
            elif line.startswith("- **WardenCB Öğret:**"): teach = line.split(":**", 1)[1].strip()
            elif line.startswith("- ") or line.startswith("**Referans"): notes.append(line.lstrip("- "))
        inner = re.search(r"\*İçinde: (.+?)\.\*", desc)
        desc = re.sub(r"\s*\*İçinde:.*$", "", desc).strip()
        if 225 <= n <= 248 and common3d:
            labs = {p["l"].lower() for p in ps}
            for r in common3d:
                if len(r) == 5 and r[0].lower() not in labs: ps.append(param(r, used))
        out[str(n)] = dict(n=n, name=name, en=en, desc=desc, params=ps, notes=notes, presetText=pres, teach=teach,
                           inner=inner.group(1) if inner else None)
    return out

if __name__ == "__main__":
    d = parse(sys.argv[1])
    dst = os.path.join(os.path.dirname(os.path.abspath(__file__)), "spec.json")
    json.dump(d, open(dst, "w"), ensure_ascii=False, indent=0)
    print(len(d), "efekt,", sum(len(v["params"]) for v in d.values()), "ayar →", dst)
