# 1000 rehberini (803–1000) okuyup spec4.json üretir: ayar tablosu (Ayar | Kontrol | Varsayılan | Aralık | AK)
import re, json, os, glob
H = os.path.dirname(os.path.abspath(__file__))
exec(open(os.path.join(H, "spec3.py")).read().split("def parse(")[0])
CODE = {"Kaydırmalı cetvel + sayısal giriş": "K", "Tam sayı": "N", "Aç/kapat": "A", "Seçim": "S", "Renk seçici": "R", "X/Y noktası": "XY", "X/Y/Z noktası": "XYZ",
        "Katman seçici": "L", "Dosya seçici": "D", "Eğri düzenleyici": "E", "Metin / ifade": "M", "Buton": "B"}
def parse4(path):
    t = open(path, encoding="utf-8").read(); out = {}
    cat = re.match(r"# (.+?) \(", t).group(1).strip()
    for chunk in re.split(r"\n(?=## \d+\. )", t):
        mm = re.match(r"## (\d+)\. (.+)", chunk)
        if not mm: continue
        n = int(mm.group(1)); name = mm.group(2).strip()
        d = re.search(r"\*\*İşlev ve ayrım:\*\*\s*(.+)", chunk); desc = d.group(1).strip() if d else name
        used = set(); ps = []
        for row in re.findall(r"^\| (?!Ayar \|)(?!---)(.+?) \|$", chunk, re.M):
            c = [x.strip() for x in row.split(" | ")]
            if len(c) < 5 or c[0].startswith("-"): continue
            lab, kon, dv, rg, ak = c[:5]; code = CODE.get(kon, "K")
            if code == "S": rg = " / ".join(o.strip() for o in rg.split("/"))
            if code in ("XY", "XYZ"): dv = dv.replace(";", ",")
            p = mk(code, lab, f"{dv} [{rg}]" if rg and rg not in ("Özel", "Katman", "RGBA / HEX") else dv, "", used, None)
            p["hint"] = ""
            if ak.startswith("Adımlı") and p.get("anim") == "yes": p["anim"] = "step"
            if code == "D": p["file"] = True
            ps.append(p)
        out[n] = dict(name=name, cat=cat, desc=desc, params=ps)
    return out
S = {}
for f in sorted(glob.glob(os.path.join(H, "guides/1000/0[1-9]-*.md"))): S.update(parse4(f))
json.dump(S, open(os.path.join(H, "spec4.json"), "w"), ensure_ascii=False, indent=0)
print(len(S), "efekt;", sum(len(v["params"]) for v in S.values()), "ayar")
