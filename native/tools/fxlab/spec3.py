# 800 rehberini (551–800) okuyup spec3.json üretir: ayarlar, gruplar, hazır şablonlar (metinden değerler çıkarılır)
import re, json, os
from spec import slug, num
from spec2 import color
H = os.path.dirname(os.path.abspath(__file__))
KIND = {"K": "jog", "N": "jog", "A": "toggle", "S": "choice", "R": "color", "XY": "jog", "XYZ": "jog", "L": "source", "D": "source", "B": "button", "E": "curve", "M": "text"}
UNITS = ["px", "%", "°", "Hz", "dB", "ms", "sn", "s", "kare", "×", "x"]
def unit_split(lab):
    w = lab.split(" ")
    if len(w) > 1 and w[-1] in UNITS: return " ".join(w[:-1]), {"s": "sn", "x": "×"}.get(w[-1], w[-1])
    return lab, ""
def fnum(s): s = s.replace("−", "-").replace(",", "."); m = re.search(r"-?\d+(?:\.\d+)?", s); return float(m.group()) if m else None
def mk(code, lab, rest, desc, used, grp):
    lab0, unit = unit_split(lab.strip())
    k = slug(lab0); b = k; i = 2
    while k in used or k == "mix": k = f"{b}{i}"; i += 1
    used.add(k); p = dict(k=k, l=lab0, g=grp, anim="yes", hint=desc.strip())
    m = re.match(r"(.*?)\s*\[(.*)\]\s*$", rest.strip()); dv, rg = (m.group(1), m.group(2)) if m else (rest.strip(), "")
    if not unit:
        for u in ("px", "%", "°", "Hz", "dB", "ms"):
            if u in dv or u in rg: unit = u; break
        if re.search(r"\d\s*sn\b|\d\s*s\b", dv): unit = "sn"
    if code in ("K", "N"):
        r = re.split(r"\s*[–-]\s*(?=[−\-]?\d)", rg.replace("/eksen", "").replace("%", "").strip(), maxsplit=1) if rg else []
        mn = fnum(r[0]) if r else 0; mx = fnum(r[1]) if len(r) > 1 else 100
        if mn is None: mn = 0
        if mx is None: mx = 100
        d = fnum(dv); d = mn if d is None else d
        integer = code == "N"; st = 1 if integer else {"%": 0.1, "px": 0.1, "°": 0.1}.get(unit, 0.01)
        if not integer and mx - mn <= 5: st = 0.01
        p.update(kind="jog", min=min(mn, mx), max=max(mn, mx), def_=min(max(d, min(mn, mx)), max(mn, mx)), step=st, jog=st, unit=unit)
        if integer: p["int"] = True
        if "×" in dv and integer: p["hint"] += " (her eksen)"
        if "tohum" in lab0.lower(): p.update(reseed=True, int=True)
    elif code == "A": p.update(kind="toggle", min=0, max=1, def_=1 if dv.lower().startswith("açık") else 0, step=1, jog=1, anim="step")
    elif code == "S":
        opts = [o.strip() for o in rg.split(" / ")] if rg else [dv]
        d = next((i for i, o in enumerate(opts) if o.lower() == dv.lower()), 0)
        p.update(kind="choice", min=0, max=len(opts) - 1, def_=d, step=1, jog=1, opts=opts, anim="step")
    elif code == "R":
        hs = re.findall(r"#[0-9A-Fa-f]{6}", dv); p.update(kind="color", min=0, max=0, def_=(hs[0].upper() if hs else color(dv)), step=1, jog=1)
        if len(hs) > 1: p["extra"] = [h.upper() for h in hs[1:]]
    elif code in ("XY", "XYZ"):
        vs = [fnum(x) for x in re.split(r"\s*,\s*(?=[−\-]?\d)", dv.replace("%", "").replace("px", "").replace("°", "").strip())]; vs = [v if v is not None else 0 for v in vs] + [0, 0, 0]
        if len(vs) >= 4 and dv.count(",") == 1 and "," in dv and not re.search(r"\d,\d", dv.replace(", ", ";")): pass
        r = re.split(r"\s*[–-]\s*(?=[−\-]?\d)", rg.replace("/eksen", "").replace("%", "").replace("px", "").strip(), maxsplit=1) if rg else []
        mn = fnum(r[0]) if r and fnum(r[0]) is not None else -4000; mx = fnum(r[1]) if len(r) > 1 and fnum(r[1]) is not None else 4000
        p.update(kind="jog", two=code == "XY", three=code == "XYZ", min=mn, max=mx, def_=vs[0], defY=vs[1], step=0.1, jog=0.1, unit=unit or ("%" if "%" in dv else ""))
        if code == "XYZ": p["defZ"] = vs[2]
    elif code in ("L", "D"): p.update(kind="source", min=0, max=0, def_="", step=1, jog=1, anim="no")
    elif code == "B": p.update(kind="button", min=0, max=0, def_=0, step=1, jog=1, anim="no")
    elif code == "E": p.update(kind="curve", min=0, max=1, def_=[[0, 0], [1, 1]], step=1, jog=1, anim="no", hint=dv)
    else: p.update(kind="text", min=0, max=0, def_="" if dv in ("-", "Boş", "(boş)") else dv, step=1, jog=1, anim="no")
    p["code"] = code
    return p
def preset_vals(text, ps):
    vals, cols = {}, {}
    for seg in re.split(r",\s*(?![0-9])|;\s*", text.rstrip(".")):
        sl = seg.lower().strip()
        best = None
        for p in ps:
            l = p["l"].lower()
            if sl.startswith(l) or l in sl: best = p if best is None or len(p["l"]) > len(best["l"]) else best
        if best is None: continue
        if best["kind"] == "toggle": vals[best["k"]] = 0 if "kapalı" in sl else 1
        elif best["kind"] == "choice":
            for i, o in enumerate(best["opts"]):
                if o.lower() in sl: vals[best["k"]] = i
        elif best["kind"] == "color":
            h = re.search(r"#[0-9A-Fa-f]{6}", seg)
            if h: cols[best["k"]] = h.group().upper()
        elif best["kind"] == "jog" and not best.get("two") and not best.get("three"):
            v = fnum(sl.replace(best["l"].lower(), " ", 1))
            if v is not None: vals[best["k"]] = max(best["min"], min(best["max"], v))
    return vals, cols
def parse(path):
    t = open(path, encoding="utf-8").read(); out = {}; sec = ""
    for chunk in re.split(r"\n(?=# \d+\. |## \d+\. )", t):
        mm = re.match(r"# (\d+)\. (.+)", chunk)
        if mm: sec = mm.group(2).split("(")[0].strip(); continue
        m = re.match(r"## (\d+)\. (.+)", chunk)
        if not m: continue
        n, name = int(m.group(1)), m.group(2).strip()
        g = lambda key: (re.search(r"\*\*" + key + r"\*\*\s*(.+)", chunk) or [None, ""])[1].strip()
        used = set(); ps = []; grp = None; pres = []; inpres = False
        for line in chunk.split("\n"):
            if line.startswith("### "):
                h = line[4:].strip(); inpres = h.startswith("Hazır"); grp = None if "temel" in h else ("Gelişmiş" if "Gelişmiş" in h else grp); continue
            pm = re.match(r"- \*\*\[(\w+)\] (.+?)\*\* — [^.]+\.\s*(.*?)\s+—\s+(.*?)\.\s", line + " ")
            if pm and not inpres: ps.append(mk(pm.group(1), pm.group(2), pm.group(3), pm.group(4), used, grp)); continue
            prm = re.match(r"- \*\*(.+?):\*\*\s*(.*)", line)
            if prm and inpres and not prm.group(1).startswith("Varsayılan"): pres.append((prm.group(1), prm.group(2)))
        presets = []
        for i, (pn, tx) in enumerate(pres):
            v, c = preset_vals(tx, ps); presets.append(dict(code="S%d" % (i + 1), name=pn, vals=v, keys={}, cols=c, at="start", text=tx))
        out[str(n)] = dict(n=n, name=name, section=sec, desc=g("Ne işe yarar\\?"), logic=g("Uygulama mantığı \\(öneri\\):"), test=g("Kullanım ve kabul testi:"),
                           load=g("Tahmini yük:"), merge=g("Birleştirme adayı:"), params=ps, presets=presets)
    return out
if __name__ == "__main__":
    d = parse(os.path.join(H, "guides/rehber-551-800.md")); json.dump(d, open(os.path.join(H, "spec3.json"), "w"), ensure_ascii=False, indent=0)
    print(len(d), "efekt,", sum(len(v["params"]) for v in d.values()), "ayar,", sum(len(v["presets"]) for v in d.values()), "şablon,", sum(1 for v in d.values() for p in v["presets"] if p["vals"] or p["cols"]), "değerli şablon")
