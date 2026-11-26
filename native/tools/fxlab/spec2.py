# Yeni efekt rehberlerini (433–462 talimat metni, 463–550 Markdown) okuyup spec2.json üretir.
import re, json, os
from spec import slug, num, unit_of
H = os.path.dirname(os.path.abspath(__file__))
COL = {"siyah": "#000000", "beyaz": "#FFFFFF", "mavi": "#2F7BFF", "açık mavi": "#8FC8FF", "kırmızı": "#E53935", "turuncu": "#FF8F1F", "açık turuncu": "#FFC27A",
       "sarı": "#FFD43B", "yeşil": "#3BB54A", "gri": "#8A8F98", "açık gri": "#C9CDD3", "koyu gri": "#44474D", "kahverengi": "#7A4E2D", "açık kahverengi": "#C9A27A",
       "mor": "#8E44D9", "pembe": "#FF6FAE", "lacivert": "#1B2A55", "altın": "#D4AF37", "gümüş": "#C0C0C8", "krem": "#F3E9D2", "bej": "#E3D3B5", "camgöbeği": "#22D3E6",
       "turkuaz": "#22C3B5", "lila": "#C7A6F0", "bordo": "#7B1E2B", "koyu mavi": "#0D2B6B", "açık yeşil": "#9BE27A", "koyu yeşil": "#1E5E2A", "açık sarı": "#FFF1A6", "bakır": "#B87333", "bronz": "#A97142", "kâğıt beyazı": "#F4EFE4", "sıcak beyaz": "#FFF1D6", "soğuk beyaz": "#E6F1FF", "kum": "#D8B97A", "kahve": "#6B4423", "lacivert mavi": "#1B2A55"}
def color(s):
    h = re.search(r"#[0-9A-Fa-f]{6}", s)
    if h: return h.group().upper()
    t = s.strip().lower().rstrip(".")
    for k in sorted(COL, key=len, reverse=True):
        if k in t: return COL[k]
    return "#FFFFFF"
def rg(s):
    s = s.replace("−", "-").replace("–", "-").replace(" ile ", "-")
    m = re.search(r"(-?\d+(?:[.,]\d+)?)\s*%?\s*-\s*%?\s*(-?\d+(?:[.,]\d+)?)", s)
    return (num(m.group(1)), num(m.group(2))) if m else None
def mk(lab, code, dv, rr, desc, used):
    k = slug(lab); b = k; i = 2
    while k in used or k in ("mix",): k = f"{b}{i}"; i += 1
    used.add(k); p = dict(k=k, l=lab, anim="yes")
    if desc: p["hint"] = desc
    dvl = dv.strip().rstrip(".")
    if code in ("K", "N"):
        r = rg(rr) or rg(dvl) or (0, 100); u = unit_of(dvl, rr) or ("%" if "%" in dvl + rr else "")
        if "°" in dvl + rr: u = "°"
        if "px" in dvl + rr: u = "px"
        if "Hz" in dvl + rr: u = "Hz"
        if re.search(r"\d\s*(sn|s)\b", dvl + " " + rr): u = "sn"
        d = num(dvl); d = r[0] if d is None else d
        integer = code == "N"; st = 1 if integer else {"%": 0.1, "px": 0.1, "°": 0.1}.get(u, 0.01)
        p.update(kind="jog", min=min(r), max=max(r), def_=d, step=st, jog=st, unit=u)
        if integer: p["int"] = True
        if "tohum" in lab.lower(): p["reseed"] = True; p["int"] = True
    elif code == "A":
        p.update(kind="toggle", min=0, max=1, def_=1 if dvl.lower().startswith("açık") else 0, step=1, jog=1, anim="step")
    elif code == "S":
        opts = [o.strip().rstrip(".") for o in re.split(r"\s/\s|,\s", rr)] if rr and rr != "-" else [o.strip().rstrip(".") for o in re.split(r",\s", dvl)]
        opts = [o[:1].upper() + o[1:] for o in opts if o]
        dd = dvl[:1].upper() + dvl[1:]
        d = opts.index(dd) if dd in opts else 0
        p.update(kind="choice", min=0, max=max(0, len(opts) - 1), def_=d, step=1, jog=1, opts=opts, anim="step")
    elif code == "R":
        p.update(kind="color", min=0, max=0, def_=color(dvl), step=1, jog=1)
    elif code in ("XY", "XYZ"):
        vs = [num(x) for x in re.split(r"[,;/]\s*", dvl.replace("−", "-")) if num(x) is not None] + [0, 0, 0]
        r = rg(rr) or (-4000, 4000); u = "°" if "°" in dvl + rr else "px" if "px" in dvl + rr else "%" if "%" in dvl + rr else ""
        p.update(kind="jog", two=code == "XY", three=code == "XYZ", min=min(r), max=max(r), def_=vs[0], defY=vs[1], step=0.1, jog=0.1, unit=u)
        if code == "XYZ": p["defZ"] = vs[2]
    elif code in ("L", "D"):
        p.update(kind="source", min=0, max=0, def_="", step=1, jog=1, anim="no", hint="Katman" if code == "L" else "Dosya / görsel")
    elif code == "M":
        p.update(kind="text", min=0, max=0, def_="" if dvl in ("-", "(boş)") else dvl, step=1, jog=1, anim="no")
    elif code == "B":
        p.update(kind="button", min=0, max=0, def_=0, step=1, jog=1, anim="no")
    else:
        p.update(kind="info", min=0, max=0, def_=0, step=1, jog=1, anim="no")
    p["code"] = code
    return p

def parse550(path):
    t = open(path, encoding="utf-8").read(); out = {}
    for b in re.split(r"\n## (?=\d+\. )", t)[1:]:
        m = re.match(r"(\d+)\. (.+)", b); n, name = int(m.group(1)), m.group(2).strip()
        g = lambda key: (re.search(r"\*\*" + key + r"\*\*\s*(.+)", b) or [None, ""])[1].strip()
        used = set(); ps = []; grp = None
        for line in b.split("\n"):
            if line.startswith("#### "): grp = line[5:].strip(); continue
            mm = re.match(r"- \*\*(.+?)\*\* \[(\w+)\] \([^)]*\) — Varsayılan: (.*?); aralık/seçenek: (.*?)\. (.*)$", line)
            if not mm:
                mm2 = re.match(r"- \*\*(.+?)\*\* \[(\w+)\] \([^)]*\) — Varsayılan: (.*?); aralık/seçenek: (.*?)\.?$", line)
                if not mm2: continue
                lab, code, dv, rr, desc = *mm2.groups(), ""
            else: lab, code, dv, rr, desc = mm.groups()
            p = mk(lab, code, dv, rr, desc, used); p["g"] = grp; ps.append(p)
        out[str(n)] = dict(n=n, name=name, desc=g("Ne işe yarar\\?"), use=g("Kullanım örnekleri:"), need=g("Gerekli giriş/altyapı:"), logic=g("Çalışma mantığı:"),
                           presetText=g("Hazır şablonlar:").rstrip("."), teach=g("WardenCB Öğret:"), params=ps)
    return out

def parseC(path):
    t = open(path, encoding="utf-8").read(); out = {}
    blocks = re.split(r"\n(?=\d+\. [^\n]+\n)", t)
    for b in blocks:
        m = re.match(r"(\d+)\. ([^\n]+)\n", b)
        if not m: continue
        n = 432 + int(m.group(1)); name = m.group(2).strip()
        used = set(); ps = []; desc = ""; pres = ""; notes = []
        for line in b.split("\n")[1:]:
            line = line.strip()
            mm = re.match(r"- \[(\w+)\] ([^:]+?)(?::\s*(.*))?$", line)
            if mm:
                code, lab, rest = mm.group(1), mm.group(2).strip().rstrip("."), (mm.group(3) or "").strip().rstrip(".")
                r = re.search(r"\(([^)]*)\)\s*$", rest); rr = r.group(1) if r else ""; dv = rest[:r.start()].strip() if r else rest
                if code == "S": rr, dv = dv, dv.split(",")[0]
                ps.append(mk(lab, code, dv, rr, "", used)); continue
            if line.startswith("Şablonlar:"): pres = line.split(":", 1)[1].strip().rstrip(".")
            elif line and not line.startswith("-") and not desc: desc = line
            elif line: notes.append(line)
        out[str(n)] = dict(n=n, name=name, desc=desc, presetText=pres, notes=notes, params=ps)
    return out

if __name__ == "__main__":
    d = parseC(os.path.join(H, "guides/rehber-433-462.txt")); d.update(parse550(os.path.join(H, "guides/rehber-463-550.md")))
    json.dump(d, open(os.path.join(H, "spec2.json"), "w"), ensure_ascii=False, indent=0)
    print(len(d), "efekt,", sum(len(v["params"]) for v in d.values()), "ayar")
    for k in ("433", "438", "463", "496", "540"): print(k, d[k]["name"], [(p["l"], p["kind"], p.get("def_"), p.get("min"), p.get("max"), p.get("unit"), p.get("opts")) for p in d[k]["params"][:6]])
