# Warden Motion efekt kataloğu üretici → app/src/main/assets/fx/catalog.json
# Her efekt: tür, Türkçe ad, İngilizce ad (aramada), kategori, işleyiş türü, açıklama, etiketler, ayarlar, hazır ayarlar
import json, os

CATS = ["Renk ve Işık", "Çizim ve Kenar", "Bulanıklık", "Bükme ve Bozulma", "Prosedürel", "3B",
        "Taşı ve Dönüştür", "Tekrar", "Maske ve Anahtar", "Opaklık ve Görünürlük", "Metin", "Diğer"]

def J(k, l, mn, mx, d, step=1, jog=None): return dict(k=k, l=l, kind="jog", min=mn, max=mx, def_=d, step=step, jog=jog or step)
def S(k, l, mn, mx, d, step=0.01): return dict(k=k, l=l, kind="slider", min=mn, max=mx, def_=d, step=step, jog=step)
def T(k, l, d=0): return dict(k=k, l=l, kind="toggle", min=0, max=1, def_=d, step=1, jog=1)
def C(k, l, d): return dict(k=k, l=l, kind="color", min=0, max=0, def_=d, step=1, jog=1)
def CH(k, l, opts, d=0): return dict(k=k, l=l, kind="choice", min=0, max=len(opts) - 1, def_=d, step=1, jog=1, opts=opts)
def XY(k, l, dx=0, dy=0, mn=-100000, mx=100000, step=1): return dict(k=k, l=l, kind="jog", min=mn, max=mx, def_=dx, defY=dy, step=step, jog=step, two=True)
def A(k, l, d=0): return J(k, l, -36000, 36000, d, 1, 0.5)
def PCT(k, l, d=100, mn=0, mx=100): return J(k, l, mn, mx, d, 1, 0.5)
def MIX(): return PCT("mix", "Karışım", 100)

E = []
def fx(type, name, en, cat, kind, desc, tags, params, presets=None, pad=None, passes=None, info=None, heavy=False):
    E.append(dict(type=type, name=name, en=en, cat=cat, kind=kind, desc=desc, tags=tags, params=params,
                  presets=presets or [], pad=pad, passes=passes, info=info, heavy=heavy))
def P(code, name, vals=None, keys=None, cols=None, at="start"):
    # keys: {param: [[t, v], ...]} t sn; at="end" ise t katmanın sonuna göre (negatif)
    return dict(code=code, name=name, vals=vals or {}, keys=keys or {}, cols=cols or {}, at=at)

# ================= 0 Renk ve Işık =================
c = 0
fx("brightness", "Parlaklık", "Brightness", c, "pixel", "Katmanı aydınlatır ya da karartır.", ["Renk", "Işık"], [PCT("amount", "Yüzde", 140, 0, 300)],
   [P("AY", "Aydınlat", {"amount": 160}), P("KR", "Karart", {"amount": 55}), P("FL", "Flaş", keys={"amount": [[0, 400], [0.35, 100]]})])
fx("contrast", "Kontrast", "Contrast", c, "pixel", "Açık ve koyu tonlar arasındaki farkı artırır ya da azaltır.", ["Renk", "Işık"], [PCT("amount", "Yüzde", 150, 0, 300)],
   [P("YK", "Yüksek kontrast", {"amount": 190}), P("DS", "Düz", {"amount": 60})])
fx("bricon", "Parlaklık / Kontrast", "Brightness/Contrast", c, "pixel", "Parlaklığı ve kontrastı birlikte ayarlar.", ["Renk", "Işık"],
   [J("bri", "Parlaklık", -100, 100, 10, 1, 0.5), J("con", "Kontrast", -100, 100, 20, 1, 0.5)],
   [P("CA", "Canlı", {"bri": 8, "con": 35}), P("SI", "Sisli", {"bri": 20, "con": -40})])
fx("exposure", "Pozlama / Gama", "Exposure/Gamma", c, "pixel", "Fotoğraf makinesi gibi pozlamayı ve gamayı ayarlar.", ["Renk", "Işık", "Fotoğraf"],
   [J("exp", "Pozlama", -5, 5, 0.6, 0.01, 0.01), J("gamma", "Gama", 0.1, 5, 1, 0.01, 0.005), J("off", "Kayma", -1, 1, 0, 0.01, 0.005)],
   [P("AP", "Aşırı pozlama", {"exp": 2}), P("DP", "Düşük pozlama", {"exp": -1.5})])
fx("saturate", "Doygunluk", "Saturation", c, "pixel", "Renklerin canlılığını artırır ya da soldurur.", ["Renk"], [PCT("amount", "Yüzde", 180, 0, 300)],
   [P("SO", "Soluk", {"amount": 40}), P("CN", "Çok canlı", {"amount": 250})])
fx("vibrance", "Doygunluk / Canlılık", "Saturation/Vibrance", c, "pixel", "Canlılık zaten doygun renklere az, soluk renklere çok etki eder.", ["Renk"],
   [J("sat", "Doygunluk", -100, 100, 0, 1, 0.5), J("vib", "Canlılık", -100, 100, 40, 1, 0.5)], [P("DO", "Doğal canlı", {"vib": 50})])
fx("hue", "Ton Kaydırma", "Hue Shift", c, "pixel", "Bütün renkleri renk çemberinde döndürür.", ["Renk"], [A("amount", "Derece", 90)],
   [P("GK", "Gökkuşağı döngüsü", keys={"amount": [[0, 0], [2, 360]]})])
fx("colortune", "Renk Ayarı", "Color Tune", c, "pixel", "Kırmızı, yeşil ve mavi kanalları ayrı ayrı ayarlar.", ["Renk"],
   [J("r", "Kırmızı", -100, 100, 15, 1, 0.5), J("g", "Yeşil", -100, 100, 0, 1, 0.5), J("b", "Mavi", -100, 100, -10, 1, 0.5), J("lit", "Işık", -100, 100, 0, 1, 0.5)],
   [P("SC", "Sıcak", {"r": 20, "b": -20}), P("SG", "Soğuk", {"r": -15, "b": 25})])
fx("temperature", "Renk Sıcaklığı", "Color Temperature", c, "pixel", "Görüntüyü sıcak (turuncu) ya da soğuk (mavi) yapar.", ["Renk", "Fotoğraf"],
   [J("temp", "Sıcaklık", -100, 100, 35, 1, 0.5), J("tint", "Yeşil-Mor", -100, 100, 0, 1, 0.5)], [P("GB", "Gün batımı", {"temp": 70}), P("KS", "Kış", {"temp": -60})])
fx("colorize", "Renklendir", "Colorize", c, "pixel", "Katmanı tek bir renge boyar, ışığı ve gölgeyi korur.", ["Renk"],
   [C("col", "Renk", "#2F7BF6"), MIX()], [P("TR", "Turkuaz", cols={"col": "#22D3C5"}), P("KZ", "Kızıl", cols={"col": "#E8333F"})])
fx("duotone", "İki Ton", "Duotone / Tint", c, "pixel", "Koyu tonları bir renge, açık tonları başka bir renge eşler.", ["Renk", "Retro"],
   [C("c1", "Koyu", "#0B1430"), C("c2", "Açık", "#22D3C5"), MIX()], [P("NE", "Neon", cols={"c1": "#2B0B4A", "c2": "#FF5BA7"}), P("GC", "Gece", cols={"c1": "#0B1430", "c2": "#3FD0F0"})])
fx("grayscale", "Siyah Beyaz", "Black & White", c, "pixel", "Renkleri kaldırır.", ["Renk", "Retro"], [PCT("amount", "Yüzde", 100)],
   [P("RG", "Renge dön", keys={"amount": [[0, 100], [1, 0]]})])
fx("sepia", "Eski Fotoğraf", "Sepia", c, "pixel", "Kahverengi tonlu eski fotoğraf görünümü.", ["Renk", "Retro"], [PCT("amount", "Yüzde", 100)])
fx("invert", "Ters Çevir", "Invert", c, "pixel", "Renkleri tersine çevirir (negatif).", ["Renk"], [PCT("amount", "Yüzde", 100)],
   [P("YS", "Yanıp sönen negatif", keys={"amount": [[0, 0], [0.1, 100], [0.2, 0], [0.3, 100], [0.4, 0]]})])
fx("threshold", "Eşik", "Threshold", c, "pixel", "Görüntüyü yalnız siyah ve beyaza ayırır.", ["Renk", "Grafik"], [J("level", "Eşik", 0, 255, 128, 1, 0.5), J("soft", "Yumuşaklık", 0, 100, 4, 1, 0.5)])
fx("posterize", "Posterleştir", "Posterize", c, "pixel", "Renk sayısını azaltarak afiş görünümü verir.", ["Renk", "Grafik", "Retro"], [J("levels", "Ton sayısı", 2, 32, 5, 1, 0.1)])
fx("levels", "Seviyeler", "Levels", c, "pixel", "Siyah ve beyaz noktalarını, orta tonları ayarlar.", ["Renk", "Fotoğraf"],
   [J("lo", "Siyah nokta", 0, 254, 20, 1, 0.5), J("hi", "Beyaz nokta", 1, 255, 235, 1, 0.5), J("mid", "Orta ton", 0.1, 5, 1, 0.01, 0.005)])
fx("gradmap", "Geçiş Haritası", "Gradient Map", c, "pixel", "Parlaklığa göre iki renkli bir geçiş uygular.", ["Renk", "Geçiş"],
   [C("c1", "Koyu", "#1B2A55"), C("c2", "Açık", "#F2C230"), MIX()], [P("AT", "Ateş", cols={"c1": "#3A0A0A", "c2": "#FFD15C"})])
fx("palettemap", "Palet Haritası", "Palette Map", c, "pixel", "Renkleri seçtiğin hazır paletteki en yakın tonlara eşler.", ["Renk", "Retro", "Grafik"],
   [CH("pal", "Palet", ["Gece", "Gün batımı", "Neon", "Türk", "Oyun"], 0), J("cycle", "Kaydırma", 0, 1, 0, 0.01, 0.005), MIX()])
fx("hotcolor", "Sıcak Renk", "Hot Color", c, "pixel", "Termal kamera gibi parlaklığı ısı renklerine çevirir.", ["Renk", "Bilim"], [J("shift", "Kaydırma", -1, 1, 0, 0.01, 0.005), MIX()])
fx("spectral", "Spektrum Haritası", "Spectral Map", c, "pixel", "Parlaklığı gökkuşağı renklerine eşler.", ["Renk", "Psikedelik"],
   [J("shift", "Kaydırma", -10, 10, 0, 0.01, 0.005), J("rep", "Tekrar", 0.5, 10, 1, 0.01, 0.01), MIX()], [P("AK", "Akan gökkuşağı", keys={"shift": [[0, 0], [2, 1]]})])
fx("fourcolor", "Dört Renkli Geçiş", "Four-color Gradient", c, "gen", "Dört köşeden yumuşak bir renk geçişi kaplar.", ["Renk", "Geçiş"],
   [C("c1", "Sol üst", "#2F7BF6"), C("c2", "Sağ üst", "#22D3C5"), C("c3", "Sol alt", "#8F7CF0"), C("c4", "Sağ alt", "#E84393"), J("speed", "Akış hızı", 0, 5, 0.3, 0.01, 0.01), MIX()])
fx("gradoverlay", "Geçiş Kaplama", "Gradient Overlay", c, "gen", "Katmanın üstüne doğrusal ya da dairesel bir geçiş koyar.", ["Renk", "Geçiş"],
   [C("c1", "Başlangıç", "#2F7BF6"), C("c2", "Bitiş", "#E84393"), A("ang", "Açı", 90), CH("gtype", "Tür", ["Doğrusal", "Dairesel"]), PCT("mix", "Karışım", 70)])
fx("highshadow", "Açık ve Koyu Tonlar", "Highlights & Shadows", c, "pixel", "Açık tonları ve gölgeleri ayrı ayrı ayarlar.", ["Renk", "Fotoğraf"],
   [J("hi", "Açık tonlar", -100, 100, -20, 1, 0.5), J("sh", "Gölgeler", -100, 100, 35, 1, 0.5)])
fx("replacecolor", "Rengi Değiştir", "Replace Color", c, "pixel", "Seçtiğin rengi başka bir renkle değiştirir.", ["Renk"],
   [C("from", "Bu renk", "#E30A17"), C("to", "Şu renk", "#2F7BF6"), PCT("tol", "Tolerans", 35), PCT("soft", "Yumuşaklık", 20)])
fx("spotcolor", "Nokta Renk", "Spot Color", c, "pixel", "Yalnız seçtiğin renk kalır, gerisi siyah beyaz olur.", ["Renk"],
   [C("keep", "Kalacak renk", "#E30A17"), PCT("tol", "Tolerans", 35), PCT("soft", "Yumuşaklık", 15)])
fx("solidcolor", "Düz Renk", "Solid Color", c, "pixel", "Katmanı şeklini koruyarak tek renge boyar.", ["Renk"], [C("col", "Renk", "#F7F8FA"), MIX()])
fx("longshadow", "Uzun Gölge", "Long Shadow", c, "pixel", "Düz tasarım tarzı, köşegen uzanan gölge.", ["Gölge", "Grafik"],
   [A("ang", "Açı", 45), J("len", "Uzunluk", 0, 1000, 120, 1, 0.5), C("col", "Renk", "#0B1430"), PCT("fade", "Solma", 60), PCT("op", "Opaklık", 80)], pad={"k": "len", "mul": 1, "add": 4})
fx("radialshadow", "Dairesel Gölge", "Radial Shadow", c, "pixel", "Bir ışık noktasından uzaklaşan gölge düşürür.", ["Gölge", "Işık"],
   [XY("light", "Işık", 0, -400), J("dist", "Uzaklık", 0, 300, 40, 1, 0.5), J("blur", "Yumuşaklık", 0, 60, 10, 0.5, 0.2), C("col", "Renk", "#0B1430"), PCT("op", "Opaklık", 70)],
   pad={"k": "dist", "mul": 2, "add": 40})
fx("lightrays", "Işık Huzmesi", "Light Rays", c, "pixel", "Parlak yerlerden bir noktaya doğru ışık huzmeleri saçar.", ["Işık", "Parlama"],
   [XY("center", "Merkez", 0, -100), J("len", "Uzunluk", 0, 100, 45, 1, 0.5), PCT("amount", "Yoğunluk", 80), J("thr", "Eşik", 0, 100, 40, 1, 0.5)], pad={"add": 60}, heavy=True)
fx("vignette", "Vinyet", "Vignette", 8, "pixel", "Kenarları karartarak bakışı ortaya çeker.", ["Maske", "Fotoğraf"],
   [PCT("amount", "Yoğunluk", 70), PCT("size", "Boyut", 55), PCT("soft", "Yumuşaklık", 50), C("col", "Renk", "#000000"), T("round", "Daire", 0)])

# ================= 1 Çizim ve Kenar =================
c = 1
fx("glow", "Parlama", "Glow", c, "pixel", "Katmanın etrafına renkli bir ışık halesi ekler.", ["Işık", "Parlama", "Neon"],
   [J("amount", "Miktar", 0, 60, 16, 0.5, 0.2), C("col", "Renk", "#3FD0F0"), PCT("str", "Güç", 100, 0, 300)],
   [P("NB", "Nabız", keys={"amount": [[0, 6], [0.5, 22], [1, 6]]}), P("AL", "Altın", cols={"col": "#F2C230"})],
   pad={"k": "amount", "mul": 3, "add": 4}, passes=[{"fs": "glow_a", "out": "A"}, {"blur": "A", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "glow_c", "aux": {"u_aux": "B"}}])
fx("shadow", "Gölge", "Drop Shadow", c, "pixel", "Katmanın altına yumuşak bir gölge düşürür.", ["Gölge"],
   [J("amount", "Yumuşaklık", 0, 60, 14, 0.5, 0.2), J("dist", "Uzaklık", 0, 200, 12, 0.5, 0.2), A("ang", "Açı", 135), C("col", "Renk", "#0D1631"), PCT("op", "Opaklık", 70)],
   pad={"k": "amount", "mul": 3, "add": 30}, passes=[{"fs": "shadow_a", "out": "A"}, {"blur": "A", "r": {"k": "amount", "mul": 0.5}, "out": "B"}, {"fs": "shadow_c", "aux": {"u_aux": "B"}}])
fx("stroke", "Kontur", "Stroke / Outline", c, "pixel", "Katmanın kenarına çizgi çeker.", ["Kenar", "Çizgi"],
   [J("width", "Kalınlık", 0, 40, 6, 0.5, 0.1), C("col", "Renk", "#F7F8FA"), CH("pos", "Konum", ["Dış", "İç", "Orta"])], pad={"k": "width", "mul": 1, "add": 3})
fx("innerglow", "İç Parlama", "Inner Glow", c, "pixel", "Kenarlardan içeri doğru parlama.", ["Işık", "Parlama"],
   [J("amount", "Miktar", 0, 60, 14, 0.5, 0.2), C("col", "Renk", "#F7F8FA"), PCT("str", "Güç", 100, 0, 300)],
   passes=[{"fs": "innerglow_a", "out": "A"}, {"blur": "A", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "innerglow_c", "aux": {"u_aux": "B"}}])
fx("innershadow", "İç Gölge", "Inner Shadow", c, "pixel", "Katmanın içine, kenardan gölge düşürür.", ["Gölge"],
   [J("amount", "Yumuşaklık", 0, 60, 10, 0.5, 0.2), J("dist", "Uzaklık", 0, 100, 8, 0.5, 0.2), A("ang", "Açı", 135), C("col", "Renk", "#000000"), PCT("op", "Opaklık", 60)],
   passes=[{"fs": "innershadow_a", "out": "A"}, {"blur": "A", "r": {"k": "amount", "mul": 0.5}, "out": "B"}, {"fs": "innershadow_c", "aux": {"u_aux": "B"}}])
fx("edges", "Kenar Bul", "Find Edges", c, "pixel", "Görüntüdeki kenarları çizgi olarak çıkarır.", ["Kenar", "Çizim"],
   [PCT("amount", "Güç", 100, 0, 400), T("inv", "Koyu zemin", 1), MIX()])
fx("emboss", "Kabartma", "Emboss / Bump", c, "pixel", "Yüzeye ışık vurmuş gibi kabartma verir.", ["Kenar", "Doku", "Işık"],
   [A("ang", "Işık açısı", 135), J("height", "Yükseklik", 0, 20, 3, 0.1, 0.05), MIX()])
fx("halftone", "Yarım Ton", "Halftone", c, "pixel", "Gazete baskısı gibi noktalardan oluşan görünüm.", ["Retro", "Grafik", "Baskı"],
   [J("size", "Nokta boyu", 2, 80, 10, 0.5, 0.1), A("ang", "Açı", 45), CH("mode", "Renk", ["Renkli", "Siyah", "Katman rengi"]), C("bg", "Zemin", "#F7F8FA")])
fx("sketch", "Karakalem", "Pencil Sketch", c, "pixel", "Kurşun kalemle çizilmiş gibi.", ["Çizim", "Sanat"], [PCT("amount", "Güç", 100, 0, 300), J("detail", "Ayrıntı", 0.5, 4, 1, 0.01, 0.01), MIX()])
fx("neonedge", "Neon Kenar", "Neon Edges", c, "pixel", "Kenarları parlayan neon çizgilere çevirir.", ["Neon", "Kenar", "Parlama"],
   [C("col", "Renk", "#22D3C5"), J("width", "Kalınlık", 0.5, 6, 1.5, 0.05, 0.02), PCT("glow", "Parlama", 120, 0, 300)], pad={"add": 20})
fx("cartoon", "Çizgi Film", "Cartoon", c, "pixel", "Düz renkler ve koyu kenar çizgileriyle çizgi film görünümü.", ["Çizim", "Sanat", "Grafik"],
   [J("levels", "Ton sayısı", 2, 12, 5, 1, 0.1), PCT("edge", "Kenar", 100, 0, 300)])
fx("roughen", "Pürüzlü Kenar", "Roughen Edges", c, "pixel", "Kenarları yırtık kâğıt gibi pürüzlendirir.", ["Kenar", "Doku"],
   [J("amount", "Miktar", 0, 60, 8, 0.5, 0.2), J("scale", "Ölçek", 1, 100, 18, 0.5, 0.2), J("speed", "Hareket", 0, 10, 0, 0.1, 0.05)], pad={"k": "amount", "mul": 1, "add": 2})
fx("drawpath", "Çizerek Belirme", "Stroke Reveal", c, "shape", "Şeklin kenarını kalemle çizer gibi ortaya çıkarır (uygulamanın şekilleri).", ["Kenar", "Çizgi", "Animasyon"],
   [PCT("prog", "İlerleme", 60), J("width", "Kalınlık", 0.5, 60, 8, 0.5, 0.1), C("col", "Renk", "#22D3C5"), T("fill", "Bitince doldur", 1)],
   [P("CZ", "Çiz ve doldur", keys={"prog": [[0, 0], [1.2, 100]]})], info="Sadece uygulamanın şekillerinde çalışır.")
fx("frame", "Çerçeve", "Border", c, "pixel", "Katmanın kutusunun çevresine çerçeve çizer.", ["Kenar", "Grafik"],
   [J("width", "Kalınlık", 0, 80, 10, 0.5, 0.1), C("col", "Renk", "#F7F8FA"), J("rad", "Köşe", 0, 200, 16, 0.5, 0.2)], pad={"k": "width", "mul": 1})

# ================= 2 Bulanıklık =================
c = 2
fx("blur", "Gauss Bulanıklığı", "Gaussian Blur", c, "pixel", "Katmanı her yöne eşit, yumuşak biçimde bulanıklaştırır.", ["Bulanık"],
   [J("amount", "Miktar", 0, 60, 8, 0.5, 0.2)], [P("BN", "Bulanıktan netleş", keys={"amount": [[0, 30], [0.6, 0]]}), P("NB", "Netten bulanığa", keys={"amount": [[-0.6, 0], [0, 30]]}, at="end")],
   pad={"k": "amount", "mul": 3, "add": 2}, passes=[{"blur": "src", "r": {"k": "amount", "mul": 1}}])
fx("boxblur", "Kutu Bulanıklığı", "Box Blur", c, "pixel", "Keskin kenarlı, kare görünümlü bulanıklık.", ["Bulanık"], [J("amount", "Miktar", 0, 60, 8, 0.5, 0.2)], pad={"k": "amount", "mul": 1.5, "add": 2},
   passes=[{"fs": "boxblur", "set": {"u_dir": [1, 0]}, "out": "A"}, {"fs": "boxblur", "in": "A", "set": {"u_dir": [0, 1]}}])
fx("dirblur", "Yönlü Bulanıklık", "Directional Blur", c, "pixel", "Tek bir yönde iz bırakan bulanıklık.", ["Bulanık", "Hız"],
   [J("amount", "Uzunluk", 0, 200, 30, 0.5, 0.2), A("ang", "Açı", 0)], pad={"k": "amount", "mul": 1, "add": 2})
fx("spinblur", "Dönme Bulanıklığı", "Spin Blur", c, "pixel", "Bir merkez etrafında dönüyormuş gibi bulanıklık.", ["Bulanık", "Hız"],
   [J("amount", "Açı", 0, 90, 12, 0.1, 0.05), XY("center", "Merkez", 0, 0)])
fx("zoomblur", "Yakınlaştırma Bulanıklığı", "Zoom Blur", c, "pixel", "Merkezden dışarı ışınsal bulanıklık.", ["Bulanık", "Hız"],
   [PCT("amount", "Miktar", 25, 0, 100), XY("center", "Merkez", 0, 0)], pad={"add": 20})
fx("lensblur", "Mercek Bulanıklığı", "Lens Blur (Bokeh)", c, "pixel", "Fotoğraf makinesi gibi yuvarlak ışık lekeli bulanıklık.", ["Bulanık", "Fotoğraf", "Işık"],
   [J("amount", "Miktar", 0, 40, 8, 0.5, 0.2), PCT("bright", "Işık lekeleri", 60)], pad={"k": "amount", "mul": 1, "add": 2}, heavy=True)
fx("tiltshift", "Minyatür", "Tilt-Shift", c, "pixel", "Ortası net, alt ve üstü bulanık; maket gibi görünür.", ["Bulanık", "Fotoğraf"],
   [J("amount", "Bulanıklık", 0, 40, 10, 0.5, 0.2), J("focus", "Odak yeri", -100, 100, 0, 1, 0.5), PCT("width", "Net alan", 30), T("sat", "Canlı renk", 1)],
   passes=[{"blur": "src", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "tiltshift", "aux": {"u_aux": "B"}}])
fx("motionblur", "Hareket Bulanıklığı", "Motion Blur", c, "special", "Katman hareket ettikçe hareket yönünde iz bırakır.", ["Bulanık", "Hız", "Hareket"],
   [S("tune", "Ayar", 0, 4, 1), T("pos", "Konum", 1), T("scl", "Ölçek", 1), T("ang", "Açı", 1)], info="Kullanmak için katmanı Taşı ve Çevir ile canlandır (bulanıklık kendiliğinden uygulanır).", heavy=True)
fx("streaks", "Işık Çizgileri", "Light Streaks", c, "pixel", "Parlak noktalardan yıldız gibi uzanan ışık çizgileri.", ["Işık", "Parlama"],
   [J("len", "Uzunluk", 0, 200, 50, 0.5, 0.2), A("ang", "Açı", 0), J("count", "Kol sayısı", 1, 4, 2, 1, 0.1), J("thr", "Eşik", 0, 100, 60, 1, 0.5)], pad={"k": "len", "mul": 1})
fx("sharpen", "Keskinleştir", "Sharpen", c, "pixel", "Ayrıntıları ve kenarları belirginleştirir.", ["Netlik", "Fotoğraf"], [PCT("amount", "Güç", 80, 0, 400), J("rad", "Yarıçap", 0.5, 10, 1.5, 0.1, 0.05)])

# ================= 3 Bükme ve Bozulma =================
c = 3
fx("fractal", "Fraktal Bükme", "Fractal Warp", c, "pixel", "Katmanı doğal, akışkan bir gürültüyle büker.", ["Bükme", "Akışkan"],
   [XY("pos", "Konum", 0, 0), XY("par", "Paralaks", 0, 0), J("mag", "Büyüklük", 0, 3, 0.2, 0.005, 0.005), J("det", "Ayrıntı", 0, 6, 1, 0.01, 0.02), J("scl", "Ölçek", 0.1, 10, 1, 0.01, 0.01)],
   [P("DL", "Dalgalanan bayrak", {"mag": 0.12, "det": 1.5}, keys={"posX": [[0, 0], [2, 400]]})], pad={"k": "mag", "mul": 260}, heavy=True)
fx("mirror", "Ayna", "Mirror (Flip)", c, "pixel", "Katmanı yatayda ters çevirir.", ["Ayna"], [])
fx("reflect", "Yansıma", "Reflect", c, "pixel", "Bir çizgiye göre katmanın yarısını öbür yarıya yansıtır.", ["Ayna", "Simetri"],
   [A("ang", "Açı", 0), J("off", "Kayma", -1000, 1000, 0, 1, 0.5)])
fx("wave", "Dalga Bükme", "Wave Warp", c, "pixel", "Katmanı dalga gibi kıvırır.", ["Bükme", "Dalga", "Akışkan"],
   [J("amp", "Yükseklik", 0, 200, 14, 0.5, 0.2), J("len", "Dalga boyu", 5, 1000, 120, 1, 0.5), J("speed", "Hız", -10, 10, 1, 0.05, 0.02), CH("dir", "Yön", ["Yatay", "Dikey"]), A("phase", "Evre", 0)],
   [P("BY", "Bayrak dalgası", {"amp": 10, "len": 160, "speed": 1.2})], pad={"k": "amp", "mul": 1})
fx("swirl", "Girdap", "Swirl / Twirl", c, "pixel", "Merkezden dönen girdap gibi büker.", ["Bükme", "Psikedelik"],
   [A("ang", "Açı", 180), PCT("rad", "Yarıçap", 60, 0, 300), XY("center", "Merkez", 0, 0)], [P("HP", "Hipnoz", keys={"ang": [[0, 0], [2, 720]]})])
fx("bulge", "Şişir / Sıkıştır", "Bulge / Pinch", c, "pixel", "Merkezi şişirir (artı) ya da içe çeker (eksi).", ["Bükme", "Mercek"],
   [J("amount", "Miktar", -100, 100, 50, 1, 0.5), PCT("rad", "Yarıçap", 60, 0, 300), XY("center", "Merkez", 0, 0)], [P("NF", "Nefes", keys={"amount": [[0, -30], [1, 40], [2, -30]]})])
fx("ripple", "Su Halkası", "Ripple", c, "pixel", "Suya taş atılmış gibi halka halka dalgalanır.", ["Bükme", "Dalga", "Su"],
   [J("amp", "Yükseklik", 0, 100, 8, 0.5, 0.2), J("len", "Dalga boyu", 5, 500, 40, 1, 0.5), J("speed", "Hız", -10, 10, 2, 0.05, 0.02), XY("center", "Merkez", 0, 0)])
fx("polar", "Kutupsal Koordinat", "Polar Coordinates", c, "pixel", "Görüntüyü daireye sarar ya da daireyi açar.", ["Bükme", "Geometrik"],
   [PCT("amount", "Miktar", 100), CH("mode", "Yön", ["Düzden daireye", "Daireden düze"])])
fx("stretchseg", "Şerit Esnetme", "Stretch Segment", c, "pixel", "Bir şeridi uzatıp görüntünün geri kalanını iter.", ["Bükme", "Glitch"],
   [J("pos", "Konum", -1000, 1000, 0, 1, 0.5), J("width", "Şerit", 0, 500, 20, 0.5, 0.2), J("amount", "Esnetme", 0, 1000, 80, 1, 0.5), CH("dir", "Yön", ["Dikey", "Yatay"])], pad={"k": "amount", "mul": 0.5})
fx("magnify", "Büyüteç", "Magnify", c, "pixel", "Bir bölgeyi büyüteç gibi büyütür.", ["Bükme", "Mercek"],
   [XY("center", "Merkez", 0, 0), J("rad", "Yarıçap", 5, 1000, 70, 1, 0.5), J("zoom", "Büyütme", 1, 10, 2, 0.01, 0.01), J("ring", "Çerçeve", 0, 20, 3, 0.1, 0.05)])
fx("tiles", "Panel Döşeme", "Tiles", c, "repeat", "Katmanı fayans gibi döşer; açı ve aralık verilebilir.", ["Tekrar", "Geometrik", "Döşeme"],
   [PCT("size", "Fayans boyu", 45, 5, 200), A("ang", "Açı", 20), J("gap", "Aralık", 0, 100, 4, 0.5, 0.2), XY("off", "Kaydır", 0, 0), T("mir", "Aynalı", 0), C("gapc", "Aralık rengi", "#F7F8FA")],
   [P("KY", "Kayan fayanslar", keys={"offX": [[0, 0], [2, 200]]})])
fx("hextile", "Altıgen Döşeme", "Hexagon Tiling", c, "repeat", "Katmanı altıgen fayanslarla döşer.", ["Tekrar", "Geometrik", "Altıgen"], [PCT("size", "Altıgen boyu", 35, 5, 200), A("ang", "Açı", 0), XY("off", "Kaydır", 0, 0)])
fx("hexrotate", "Altıgen Karo Döndür", "Hexagon Tile Rotate", c, "pixel", "Katmanı altıgen karolara bölüp her birini döndürür.", ["Altıgen", "Geometrik", "Geçiş"],
   [J("size", "Karo boyu", 4, 500, 40, 0.5, 0.2), A("ang", "Açı", 60), PCT("rand", "Rastgelelik", 50)], [P("AG", "Altıgen geçiş", keys={"ang": [[0, 180], [0.8, 0]]})])
fx("hexshift", "Altıgen Karo Kaydır", "Hexagon Tile Shift", c, "pixel", "Altıgen karoların içeriğini rastgele yönlere kaydırır.", ["Altıgen", "Geometrik", "Glitch"],
   [J("size", "Karo boyu", 4, 500, 40, 0.5, 0.2), J("amount", "Kaydırma", 0, 500, 30, 0.5, 0.2), J("seed", "Tohum", 0, 100, 1, 1, 0.2)])
fx("tilerotate", "Karo Döndür", "Tile Rotate", c, "pixel", "Kare karolara bölüp her birini döndürür.", ["Geometrik", "Geçiş"], [J("size", "Karo boyu", 4, 500, 40, 0.5, 0.2), A("ang", "Açı", 90), PCT("rand", "Rastgelelik", 50)])
fx("tileshift", "Karo Kaydır", "Tile Shift", c, "pixel", "Kare karoların içeriğini rastgele kaydırır.", ["Geometrik", "Glitch"], [J("size", "Karo boyu", 4, 500, 40, 0.5, 0.2), J("amount", "Kaydırma", 0, 500, 30, 0.5, 0.2), J("seed", "Tohum", 0, 100, 1, 1, 0.2)])
fx("kaleido", "Kaleydoskop", "Kaleidoscope", c, "pixel", "Görüntüyü dilimleyip simetrik bir desene çevirir.", ["Simetri", "Psikedelik", "Ayna"],
   [J("seg", "Dilim", 2, 24, 6, 1, 0.1), A("ang", "Açı", 0), XY("center", "Merkez", 0, 0)], [P("DN", "Dönen", keys={"ang": [[0, 0], [2, 120]]})])
fx("offset", "Kaydır (Sarmala)", "Offset / Wrap", c, "pixel", "İçeriği kaydırır; taşan kısım öbür taraftan girer.", ["Döşeme"], [XY("off", "Kaydır", 40, 0)], [P("AK", "Sonsuz akış", keys={"offX": [[0, 0], [2, 400]]})])
fx("fisheye", "Balık Gözü", "Fisheye", c, "pixel", "Geniş açılı mercek gibi kenarları büker.", ["Mercek", "Fotoğraf"], [J("amount", "Miktar", -100, 100, 60, 1, 0.5)])
fx("pixelate", "Pikselleştir", "Pixelate", c, "pixel", "Katmanı büyük piksellere böler.", ["Retro", "Oyun", "Sansür"], [J("size", "Piksel boyu", 1, 200, 12, 0.5, 0.2)],
   [P("PG", "Pikselden gel", keys={"size": [[0, 60], [0.8, 1]]})])
fx("mosaic", "Mozaik", "Mosaic", c, "pixel", "Ortalama renkli, ince aralıklı mozaik taşları.", ["Retro", "Döşeme"], [J("size", "Taş boyu", 2, 200, 14, 0.5, 0.2), J("gap", "Aralık", 0, 20, 1.5, 0.1, 0.05), C("gapc", "Aralık rengi", "#0B1430")])
fx("rgbsplit", "Renk Kayması", "RGB Split", c, "pixel", "Kırmızı, yeşil ve mavi kanalları birbirinden ayırır.", ["Glitch", "Retro"], [J("amount", "Uzaklık", 0, 100, 8, 0.1, 0.05), A("ang", "Açı", 0)], pad={"k": "amount", "mul": 1})
fx("glitch", "Bozuk Sinyal", "Glitch", c, "pixel", "Dijital bozulma: kayan bloklar ve renk ayrışması.", ["Glitch"], [PCT("amount", "Miktar", 50), J("speed", "Hız", 0, 30, 8, 0.1, 0.05), J("seed", "Tohum", 0, 100, 1, 1, 0.2)], pad={"add": 30})
fx("displace", "Türbülanslı Yer Değiştirme", "Turbulent Displace", c, "pixel", "Kaynayan, akan bir gürültüyle büker.", ["Bükme", "Akışkan", "Ateş"],
   [J("amount", "Miktar", 0, 200, 20, 0.5, 0.2), J("size", "Ölçek", 5, 1000, 80, 1, 0.5), J("speed", "Hız", 0, 10, 1, 0.05, 0.02), J("det", "Ayrıntı", 0, 5, 2, 0.01, 0.02)], pad={"k": "amount", "mul": 1})
fx("shear", "Eğ", "Skew", c, "pixel", "Katmanı yana yatırır (italik gibi).", ["Dönüştür"], [J("x", "Yatay", -89, 89, 15, 0.5, 0.2), J("y", "Dikey", -89, 89, 0, 0.5, 0.2)], pad={"add": 0})
fx("slices", "Dilim Kaydır", "Slice Shift", c, "pixel", "Yatay dilimleri rastgele sağa sola kaydırır.", ["Glitch"], [J("count", "Dilim", 2, 100, 14, 1, 0.1), J("amount", "Kaydırma", 0, 300, 30, 0.5, 0.2), J("speed", "Hız", 0, 20, 3, 0.1, 0.05)], pad={"k": "amount", "mul": 1})
fx("squeeze", "Sıvı Esneme", "Liquid Stretch", c, "pixel", "Jöle gibi esneyip sallanır.", ["Bükme", "Akışkan"], [PCT("amount", "Miktar", 30), J("speed", "Hız", 0, 10, 2, 0.05, 0.02)], pad={"add": 0})

# ================= 4 Prosedürel =================
c = 4
G = lambda: [MIX()]
fx("checker", "Dama", "Checker", c, "gen", "Dama tahtası deseni.", ["Desen", "Geometrik"], [J("size", "Kare boyu", 2, 500, 40, 0.5, 0.2), C("c1", "Renk 1", "#2F7BF6"), C("c2", "Renk 2", "#F7F8FA"), A("ang", "Açı", 0), J("speed", "Kayma", -200, 200, 0, 1, 0.5)] + G())
fx("stripes", "Şeritler", "Stripes", c, "gen", "Çapraz ya da düz şerit deseni.", ["Desen", "Geometrik"], [J("width", "Şerit", 1, 500, 24, 0.5, 0.2), PCT("ratio", "Oran", 50), A("ang", "Açı", 45), C("c1", "Renk 1", "#2F7BF6"), C("c2", "Renk 2", "#F7F8FA"), J("speed", "Kayma", -500, 500, 40, 1, 0.5)] + G())
fx("grid", "Izgara", "Grid", c, "gen", "Kareli çizgi ızgarası.", ["Desen", "Geometrik"], [J("size", "Kare boyu", 4, 500, 40, 0.5, 0.2), J("lw", "Çizgi", 0.5, 50, 3, 0.1, 0.05), C("c1", "Çizgi", "#F7F8FA"), C("c2", "Zemin", "#2F7BF6"), PCT("bgop", "Zemin opaklığı", 100)] + G())
fx("dots", "Noktalar", "Dots", c, "gen", "Düzenli nokta deseni.", ["Desen", "Geometrik", "Retro"], [J("size", "Aralık", 4, 500, 30, 0.5, 0.2), PCT("rad", "Nokta boyu", 40, 1, 100), C("c1", "Nokta", "#F7F8FA"), C("c2", "Zemin", "#2F7BF6"), T("stag", "Kaydırmalı", 1)] + G())
fx("noise", "Gürültü", "Noise", c, "gen", "Televizyon karlanması gibi kumlu gürültü.", ["Doku", "Retro"], [PCT("amount", "Miktar", 35), J("speed", "Hız", 0, 60, 24, 1, 0.5), T("mono", "Siyah beyaz", 1), J("size", "Tane", 1, 20, 1, 0.1, 0.05)])
fx("clouds", "Bulutlar", "Clouds", c, "gen", "Yumuşak, akan bulut dokusu.", ["Doğa", "Doku"], [J("scale", "Ölçek", 10, 2000, 200, 1, 0.5), J("det", "Ayrıntı", 0, 7, 4, 0.01, 0.02), J("speed", "Hız", 0, 5, 0.3, 0.01, 0.01), C("c1", "Gök", "#2F7BF6"), C("c2", "Bulut", "#F7F8FA")] + G())
fx("blocknoise", "Blok Gürültü", "Block Noise", c, "gen", "Rastgele renkli bloklar (dijital bozulma).", ["Glitch", "Desen"], [J("size", "Blok", 2, 300, 24, 0.5, 0.2), J("speed", "Hız", 0, 30, 6, 0.1, 0.05), PCT("sat", "Renk", 100)] + G())
fx("ridges", "Fraktal Sırtlar", "Fractal Ridges", c, "gen", "Dağ sırtları gibi keskin fraktal desen.", ["Doku", "Doğa"], [J("scale", "Ölçek", 10, 2000, 160, 1, 0.5), J("det", "Ayrıntı", 0, 7, 4, 0.01, 0.02), J("speed", "Hız", 0, 5, 0.2, 0.01, 0.01), C("c1", "Koyu", "#0B1430"), C("c2", "Açık", "#F7F8FA")] + G())
fx("hexarray", "Altıgen Dizisi", "Hexagon Array", c, "gen", "Katmanın dolu kısmını altıgenlerle kaplar.", ["Desen", "Geometrik", "Altıgen"],
   [J("size", "Altıgen boyu", 4, 500, 34, 0.5, 0.2), PCT("gap", "Aralık", 12), C("c1", "Altıgen", "#F7F8FA"), C("c2", "Zemin", "#2F7BF6"), PCT("rand", "Rastgele renk", 0)] + G(),
   [P("HS", "Altıgen silme", keys={"gap": [[-0.8, 0], [0, 100]]}, at="end"), P("HM", "Altıgen mozaik", {"rand": 60})])
fx("hexcells", "Altıgen Hücreler", "Hexagon Cells", c, "gen", "Yanıp sönen altıgen hücreler.", ["Desen", "Altıgen", "Bilim"], [J("size", "Hücre", 4, 500, 30, 0.5, 0.2), J("speed", "Hız", 0, 10, 1, 0.05, 0.02), C("c1", "Renk", "#22D3C5"), C("c2", "Zemin", "#0B1430")] + G())
fx("iridescence", "Yanardöner", "Iridescence", c, "gen", "Sabun köpüğü gibi akan yanardöner renkler.", ["Renk", "Akışkan", "Psikedelik"], [J("scale", "Ölçek", 10, 2000, 260, 1, 0.5), J("speed", "Hız", 0, 5, 0.4, 0.01, 0.01), PCT("mix", "Karışım", 70)])
fx("lensflare", "Mercek Parlaması", "Lens Flare", c, "gen", "Güneş mercekten geçmiş gibi parlama ve halkalar.", ["Işık", "Parlama"], [XY("pos", "Işık", -120, -120), PCT("size", "Boyut", 100, 10, 400), C("col", "Renk", "#FFE6A8"), PCT("str", "Güç", 100, 0, 300)])
fx("lightning", "Şimşek", "Lightning", c, "gen", "Çakan şimşek.", ["Işık", "Doğa", "Enerji"], [XY("a", "Başlangıç", 0, -200), XY("b", "Bitiş", 0, 200), J("width", "Kalınlık", 0.5, 20, 3, 0.1, 0.05), J("speed", "Çakma", 0, 30, 8, 0.1, 0.05), C("col", "Renk", "#9AD8FF"), J("branch", "Dal", 0, 1, 0.5, 0.01, 0.01)], pad={"add": 0})
fx("rays", "Işınsal Çizgiler", "Radial Rays", c, "gen", "Merkezden yayılan güneş ışınları deseni.", ["Desen", "Retro", "Geometrik"], [J("count", "Işın", 2, 64, 16, 1, 0.1), C("c1", "Renk 1", "#2F7BF6"), C("c2", "Renk 2", "#F7F8FA"), J("speed", "Dönme", -360, 360, 20, 1, 0.5), XY("center", "Merkez", 0, 0)] + G())
fx("ribbon", "Kurdele", "Ribbon", c, "gen", "Süzülen parlak kurdeleler.", ["Işık", "Akışkan", "Neon"], [J("count", "Kurdele", 1, 8, 3, 1, 0.1), J("width", "Kalınlık", 0.5, 60, 6, 0.1, 0.05), J("speed", "Hız", 0, 5, 0.6, 0.01, 0.01), C("col", "Renk", "#8F7CF0"), PCT("glow", "Parlama", 100, 0, 300)])
fx("starfield", "Yıldız Alanı", "Starfield", c, "gen", "Uzayda ileri gidiyormuş gibi yıldızlar.", ["Uzay", "Işık"], [PCT("density", "Yoğunluk", 50), J("speed", "Hız", 0, 10, 1, 0.05, 0.02), PCT("size", "Boyut", 100, 10, 400)])
fx("star", "Parıltı Yıldızı", "Star", c, "gen", "Parlayan, ışık saçan yıldız.", ["Işık", "Parlama", "Uzay"], [XY("pos", "Konum", 0, 0), J("points", "Kol", 2, 16, 4, 1, 0.1), PCT("size", "Boyut", 100, 10, 500), C("col", "Renk", "#BFF4FF"), J("spin", "Dönme", -360, 360, 20, 1, 0.5)])
fx("turbulence", "Türbülans", "Turbulence", c, "gen", "Duman gibi kıvrılan gürültü.", ["Doku", "Akışkan", "Duman"], [J("scale", "Ölçek", 10, 2000, 140, 1, 0.5), J("det", "Ayrıntı", 0, 7, 5, 0.01, 0.02), J("speed", "Hız", 0, 5, 0.5, 0.01, 0.01), C("c1", "Koyu", "#0B1430"), C("c2", "Açık", "#8FA6D6")] + G())
fx("plasma", "Plazma", "Plasma", c, "gen", "Akan, renkli plazma.", ["Renk", "Psikedelik", "Retro"], [J("scale", "Ölçek", 10, 2000, 180, 1, 0.5), J("speed", "Hız", 0, 10, 1, 0.05, 0.02)] + G())
fx("voronoi", "Hücreler", "Voronoi Cells", c, "gen", "Hareket eden hücre (Voronoi) deseni.", ["Desen", "Doğa", "Bilim"], [J("size", "Hücre", 4, 500, 50, 0.5, 0.2), J("speed", "Hız", 0, 5, 0.5, 0.01, 0.01), C("c1", "Kenar", "#22D3C5"), C("c2", "İç", "#0B1430"), J("edge", "Kenar kalınlığı", 0, 20, 2, 0.1, 0.05)] + G())
fx("gradientfill", "Geçiş Dolgusu", "Gradient Fill", c, "gen", "Katmanı iki renkli geçişle doldurur.", ["Renk", "Geçiş"], [C("c1", "Başlangıç", "#22D3C5"), C("c2", "Bitiş", "#2F7BF6"), A("ang", "Açı", 90), CH("gtype", "Tür", ["Doğrusal", "Dairesel"])] + G())
fx("snow", "Kar Yağışı", "Snow", c, "gen", "Yağan kar taneleri.", ["Doğa", "Kış", "Parçacık"], [PCT("density", "Yoğunluk", 50), J("speed", "Hız", 0, 10, 1, 0.05, 0.02), PCT("size", "Boyut", 100, 10, 400), J("wind", "Rüzgâr", -10, 10, 1, 0.05, 0.02)])
fx("rain", "Yağmur", "Rain", c, "gen", "Yağmur damlaları.", ["Doğa", "Parçacık"], [PCT("density", "Yoğunluk", 50), J("speed", "Hız", 0, 10, 2, 0.05, 0.02), A("ang", "Açı", 10), C("col", "Renk", "#BFD8FF")])
fx("confetti", "Konfeti", "Confetti", c, "gen", "Dökülen renkli konfeti.", ["Kutlama", "Parçacık"], [PCT("density", "Yoğunluk", 50), J("speed", "Hız", 0, 10, 1, 0.05, 0.02), PCT("size", "Boyut", 100, 10, 400)])
fx("bubbles", "Kabarcıklar", "Bubbles", c, "gen", "Yükselen sabun kabarcıkları.", ["Parçacık", "Su"], [PCT("density", "Yoğunluk", 40), J("speed", "Hız", 0, 10, 1, 0.05, 0.02), PCT("size", "Boyut", 100, 10, 400)])
fx("fire", "Ateş", "Fire", c, "gen", "Yanan alevler.", ["Doğa", "Ateş", "Parçacık"], [PCT("height", "Yükseklik", 70), J("speed", "Hız", 0, 10, 1.5, 0.05, 0.02), J("scale", "Ölçek", 10, 1000, 120, 1, 0.5)] + G())

# ================= 5 3B =================
c = 5
R3 = lambda dx=20, dy=30, dz=0, spin=40: [A("rx", "X dönüş", dx), A("ry", "Y dönüş", dy), A("rz", "Z dönüş", dz), J("spin", "Dönme hızı", -720, 720, spin, 1, 0.5), PCT("size", "Boyut", 70, 10, 200), PCT("light", "Işık", 70), PCT("persp", "Perspektif", 50)]
fx("flip3d", "3B Çevir", "Flip Layer (3D)", c, "3d", "Katmanı 3B uzayda bir eksende çevirir.", ["3B", "Geçiş"], [A("rx", "X dönüş", 0), A("ry", "Y dönüş", 35), A("rz", "Z dönüş", 0), J("spin", "Dönme hızı", -720, 720, 0, 1, 0.5), PCT("persp", "Perspektif", 50), T("back", "Arka yüz", 1)],
   [P("YD", "Yatay dönüş", keys={"ry": [[0, 0], [1, 360]]}), P("DD", "Dikey dönüş", keys={"rx": [[0, 0], [1, 360]]}), P("GR", "Geçiş: giriş", keys={"ry": [[0, -90], [0.6, 0]]}), P("GC", "Geçiş: çıkış", keys={"ry": [[-0.6, 0], [0, 90]]}, at="end")], pad={"add": 0})
fx("cube", "Küp", "Cube", c, "3d", "Katmanı her yüzünde taşıyan dönen küp.", ["3B", "Şekil"], R3())
fx("sphere", "Küre", "Sphere", c, "3d", "Katmanı bir kürenin yüzeyine sarar.", ["3B", "Şekil", "Gezegen"], R3(10, 0, 0, 40))
fx("cylinder", "Silindir", "Cylinder", c, "3d", "Katmanı silindirin yan yüzüne sarar.", ["3B", "Şekil"], R3(15, 0, 0, 40))
fx("cone", "Koni", "Cone", c, "3d", "Katmanı koninin yüzüne sarar.", ["3B", "Şekil"], R3(-15, 0, 0, 40))
fx("pyramid", "Piramit", "Pyramid", c, "3d", "Dört yüzlü piramit.", ["3B", "Şekil"], R3(-15, 20, 0, 40))
fx("octahedron", "Sekizyüzlü", "Octahedron", c, "3d", "Sekiz yüzlü elmas biçimli şekil.", ["3B", "Şekil", "Zar"], R3(15, 20, 0, 40))
fx("hexprism", "Altıgen Prizma", "Hexagonal Prism", c, "3d", "Altıgen tabanlı prizma.", ["3B", "Şekil", "Altıgen"], R3(25, 0, 0, 40))
fx("torus", "Simit", "Torus", c, "3d", "Katmanı simit biçiminde bir halkaya sarar.", ["3B", "Şekil"], R3(55, 0, 0, 40))
fx("heart3d", "Kalp", "Heart (3D)", c, "3d", "Kabarık 3B kalp; katman yüzey dokusu olur.", ["3B", "Şekil", "Sevgi"], R3(0, 0, 0, 30), [P("KA", "Kalp atışı", keys={"size": [[0, 64], [0.15, 76], [0.3, 66], [0.45, 74], [0.9, 64]]})])
fx("starprism", "Yıldız Prizma", "Star Prism", c, "3d", "Kalın, 3B beş köşeli yıldız.", ["3B", "Şekil"], R3(10, 0, 0, 40))
fx("capsule", "Kapsül", "Capsule", c, "3d", "Uçları yuvarlak kapsül.", ["3B", "Şekil"], R3(0, 0, 70, 40))
fx("extrude", "Kalınlık Ver", "Extrude", c, "3d", "Katmanın şekline 3B kalınlık verir.", ["3B", "Grafik"], [J("depth", "Kalınlık", 0, 300, 40, 0.5, 0.2), A("rx", "X dönüş", -20), A("ry", "Y dönüş", 30), J("spin", "Dönme hızı", -720, 720, 30, 1, 0.5), C("side", "Yan renk", "#1B2A55"), PCT("light", "Işık", 70)], pad={"k": "depth", "mul": 1.5, "add": 20})

# ================= 6 Taşı ve Dönüştür =================
c = 6
fx("sway", "Oto-Sallanma", "Swing (Auto Sway)", c, "xform", "Katmanı iki yana yumuşakça sallar.", ["Hareket", "Döndür"], [J("amount", "Açı", 0, 45, 6, 0.5, 0.2), J("speed", "Hız", 0.1, 5, 0.8, 0.05, 0.02)],
   [P("HF", "Hafif", {"amount": 4, "speed": 0.6}), P("GC", "Güçlü", {"amount": 14, "speed": 1.2})])
fx("shake", "Rastgele Titreşim", "Auto Shake", c, "xform", "Katmanı rastgele titretir.", ["Hareket", "Titreşim"], [J("amount", "Mesafe", 0, 60, 8, 0.5, 0.2), J("speed", "Hız", 0.1, 5, 1.5, 0.05, 0.02)],
   [P("DP", "Deprem", {"amount": 18, "speed": 3})])
fx("spin", "Döndür", "Spin", c, "xform", "Katmanı sürekli döndürür.", ["Hareket", "Döndür"], [J("speed", "Hız (°/sn)", -1440, 1440, 90, 1, 0.5)])
fx("pulse", "Nabız", "Pulse Size", c, "xform", "Katmanı ritimle büyütüp küçültür.", ["Hareket", "Ölçek"], [PCT("amount", "Miktar", 12, 0, 100), J("speed", "Hız", 0.05, 10, 1.5, 0.05, 0.02)])
fx("bounce", "Zıpla", "Bounce", c, "xform", "Katman yerinde zıplar.", ["Hareket"], [J("height", "Yükseklik", 0, 1000, 60, 1, 0.5), J("speed", "Hız", 0.05, 10, 1.4, 0.05, 0.02), T("squash", "Ezilme", 1)])
fx("wiggle", "Kıpırdat", "Wiggle", c, "xform", "Yumuşak ve rastgele kıpırdanma (konum ve açı).", ["Hareket", "Rastgele"], [J("amount", "Mesafe", 0, 300, 20, 0.5, 0.2), J("rot", "Açı", 0, 90, 4, 0.5, 0.2), J("speed", "Hız", 0.05, 10, 1, 0.05, 0.02)])
fx("orbit", "Yörünge", "Orbit", c, "xform", "Katman bir daire üzerinde döner.", ["Hareket", "Döndür"], [J("rad", "Yarıçap", 0, 1000, 80, 1, 0.5), J("speed", "Hız", -10, 10, 0.5, 0.01, 0.01), T("face", "Yöne bak", 0)])
fx("float", "Süzül", "Float", c, "xform", "Havada süzülür gibi yavaşça yukarı aşağı.", ["Hareket"], [J("amount", "Mesafe", 0, 300, 18, 0.5, 0.2), J("speed", "Hız", 0.05, 10, 0.6, 0.05, 0.02), J("tilt", "Eğilme", 0, 30, 3, 0.1, 0.05)])
fx("pendulum", "Sarkaç", "Pendulum", c, "xform", "Üst kenarından asılı gibi sallanır.", ["Hareket", "Döndür"], [J("amount", "Açı", 0, 90, 20, 0.5, 0.2), J("speed", "Hız", 0.05, 5, 0.7, 0.05, 0.02)])
fx("heartbeat", "Kalp Atışı", "Heartbeat", c, "xform", "İki vuruşlu kalp atışı ritmi.", ["Hareket", "Ölçek", "Sevgi"], [PCT("amount", "Miktar", 15, 0, 100), J("bpm", "Nabız (vuruş/dk)", 20, 240, 70, 1, 0.5)])
fx("squash", "Ez ve Esnet", "Squash & Stretch", c, "xform", "Çizgi film gibi ezilip esner.", ["Hareket", "Ölçek"], [PCT("amount", "Miktar", 15, 0, 100), J("speed", "Hız", 0.05, 10, 1.5, 0.05, 0.02)])
fx("coinflip", "Para Dönüşü", "Coin Flip", c, "xform", "Yere düşmüş para gibi kendi ekseninde döner.", ["Hareket", "Döndür"], [J("speed", "Hız", -5, 5, 0.8, 0.01, 0.01), CH("axis", "Eksen", ["Dikey", "Yatay"])])
fx("jump", "Rastgele Sıçrama", "Random Displacement", c, "xform", "Belirli aralıklarla rastgele yerlere sıçrar.", ["Hareket", "Rastgele", "Glitch"], [J("amount", "Mesafe", 0, 500, 30, 0.5, 0.2), J("rate", "Sıklık", 0.5, 30, 6, 0.1, 0.05)])
fx("slidein", "Kayarak Giriş", "Slide In", c, "xform", "Katman başında kenardan kayarak gelir.", ["Giriş", "Animasyon"], [CH("dir", "Yön", ["Soldan", "Sağdan", "Yukarıdan", "Aşağıdan"]), J("dur", "Süre", 0.05, 5, 0.6, 0.01, 0.01), J("dist", "Uzaklık", 0, 3000, 600, 1, 0.5)])
fx("slideout", "Kayarak Çıkış", "Slide Out", c, "xform", "Katman sonunda kenara kayarak gider.", ["Çıkış", "Animasyon"], [CH("dir", "Yön", ["Sola", "Sağa", "Yukarı", "Aşağı"]), J("dur", "Süre", 0.05, 5, 0.6, 0.01, 0.01), J("dist", "Uzaklık", 0, 3000, 600, 1, 0.5)])
fx("popin", "Büyüyerek Belir", "Pop In", c, "xform", "Katman başında yaylanarak büyür.", ["Giriş", "Animasyon"], [J("dur", "Süre", 0.05, 5, 0.5, 0.01, 0.01), PCT("over", "Yaylanma", 30)])
fx("popout", "Küçülerek Kaybol", "Pop Out", c, "xform", "Katman sonunda küçülerek kaybolur.", ["Çıkış", "Animasyon"], [J("dur", "Süre", 0.05, 5, 0.4, 0.01, 0.01)])

# ================= 7 Tekrar =================
c = 7
fx("gridrepeat", "Izgara Tekrarı", "Grid Repeat", c, "repeat", "Katmanı satır ve sütunlar hâlinde çoğaltır.", ["Tekrar", "Geometrik"], [J("cols", "Sütun", 1, 20, 3, 1, 0.1), J("rows", "Satır", 1, 20, 3, 1, 0.1), PCT("sx", "Yatay aralık", 110, 0, 400), PCT("sy", "Dikey aralık", 110, 0, 400)],
   pad={"add": 0})
fx("linrepeat", "Doğrusal Tekrar", "Linear Repeat", c, "repeat", "Katmanı bir doğru boyunca çoğaltır; her kopya küçülebilir, dönebilir.", ["Tekrar"],
   [J("count", "Kopya", 1, 40, 5, 1, 0.1), XY("off", "Aralık", 60, 0), PCT("scl", "Ölçek değişimi", 100, 10, 200), A("rot", "Dönme değişimi", 0), PCT("fade", "Solma", 0)], pad={"add": 0})
fx("radrepeat", "Dairesel Tekrar", "Radial Repeat", c, "repeat", "Katmanı bir dairenin çevresine dizer.", ["Tekrar", "Simetri"], [J("count", "Kopya", 1, 40, 8, 1, 0.1), J("rad", "Yarıçap", 0, 2000, 160, 1, 0.5), T("face", "Merkeze dön", 1), A("ang", "Başlangıç açısı", 0), J("speed", "Dönme", -360, 360, 0, 1, 0.5)], pad={"add": 0})
fx("scatter", "Saçılım Tekrarı", "Scatter Repeat", c, "repeat", "Katmanın kopyalarını rastgele saçar.", ["Tekrar", "Rastgele"], [J("count", "Kopya", 1, 60, 14, 1, 0.1), J("area", "Alan", 0, 3000, 400, 1, 0.5), PCT("svar", "Ölçek farkı", 50), A("rvar", "Açı farkı", 180), J("seed", "Tohum", 0, 100, 1, 1, 0.2), J("speed", "Süzülme", 0, 5, 0, 0.01, 0.01)], pad={"add": 0})
fx("spiral", "Sarmal Tekrar", "Spiral Repeat", c, "repeat", "Kopyaları sarmal boyunca dizer.", ["Tekrar", "Psikedelik"], [J("count", "Kopya", 1, 60, 16, 1, 0.1), A("step", "Açı adımı", 30), J("grow", "Açılma", 0, 200, 14, 0.5, 0.2), PCT("scl", "Ölçek değişimi", 96, 50, 150), J("speed", "Dönme", -360, 360, 30, 1, 0.5)], pad={"add": 0})
fx("echo", "Yankı", "Echo", c, "echo", "Katmanın az önceki hâllerini solarak arkasında bırakır.", ["Tekrar", "Hareket", "İz"], [J("count", "Kopya", 1, 20, 5, 1, 0.1), J("delay", "Gecikme (sn)", 0.01, 1, 0.08, 0.005, 0.002), PCT("decay", "Solma", 60)], info="Katmanı Taşı ve Çevir ile canlandırınca iz bırakır.")
fx("mirrorrepeat", "Ayna Kopya", "Mirror Repeat", c, "repeat", "Katmanın yanına aynalanmış bir kopyasını koyar.", ["Tekrar", "Ayna", "Simetri"], [CH("dir", "Yön", ["Yatay", "Dikey", "Dört yön"]), J("gap", "Aralık", -500, 500, 0, 0.5, 0.2)], pad={"add": 0})

# ================= 8 Maske ve Anahtar =================
c = 8
fx("chromakey", "Kroma Anahtarı", "Chroma Key", c, "pixel", "Yeşil (ya da seçtiğin) perdeyi saydam yapar.", ["Maske", "Anahtar", "Video"], [C("key", "Perde rengi", "#22B14C"), PCT("tol", "Tolerans", 30), PCT("soft", "Yumuşaklık", 12), PCT("spill", "Renk taşması", 50)])
fx("lumakey", "Parlaklık Anahtarı", "Luma Key", c, "pixel", "Koyu (ya da açık) yerleri saydam yapar.", ["Maske", "Anahtar"], [PCT("thr", "Eşik", 30), PCT("soft", "Yumuşaklık", 10), T("inv", "Açığı sil", 0)])
fx("solidmatte", "Düz Mat", "Solid Matte", c, "pixel", "Katmanın arkasındaki saydam alanı düz bir renkle doldurur.", ["Maske", "Renk"], [C("col", "Renk", "#F7F8FA"), PCT("op", "Opaklık", 100), J("rad", "Köşe", 0, 200, 0, 0.5, 0.2)])
fx("choke", "Kenar Daralt / Genişlet", "Matte Choker", c, "pixel", "Saydamlığın kenarını içeri çeker ya da dışarı taşırır.", ["Maske", "Kenar"], [J("amount", "Miktar", -30, 30, -3, 0.1, 0.05), J("soft", "Yumuşaklık", 0, 30, 1, 0.1, 0.05)], pad={"k": "amount", "mul": 1, "add": 2})
fx("feather", "Kenar Yumuşat", "Feather", c, "pixel", "Kenarları yumuşak bir geçişle saydamlaştırır.", ["Maske", "Kenar", "Bulanık"], [J("amount", "Miktar", 0, 100, 14, 0.5, 0.2)])
fx("alphathr", "Saydamlık Eşiği", "Alpha Threshold", c, "pixel", "Yarı saydam yerleri ya tam görünür ya tam saydam yapar.", ["Maske"], [PCT("thr", "Eşik", 50)])
fx("linwipe", "Doğrusal Silme", "Linear Wipe", c, "pixel", "Katmanı bir doğru boyunca siler ya da açar.", ["Maske", "Geçiş"], [PCT("prog", "İlerleme", 50), A("ang", "Açı", 0), J("feather", "Yumuşaklık", 0, 500, 20, 0.5, 0.2)],
   [P("GR", "Giriş", keys={"prog": [[0, 100], [0.7, 0]]}), P("CK", "Çıkış", keys={"prog": [[-0.7, 0], [0, 100]]}, at="end")])
fx("radwipe", "Saat Silmesi", "Radial Wipe", c, "pixel", "Saat ibresi gibi dönerek siler ya da açar.", ["Maske", "Geçiş"], [PCT("prog", "İlerleme", 35), A("ang", "Başlangıç", 0), J("feather", "Yumuşaklık", 0, 90, 2, 0.1, 0.05), T("ccw", "Ters yön", 0)],
   [P("GR", "Giriş", keys={"prog": [[0, 100], [0.8, 0]]})])
fx("iris", "Dairesel Açılış", "Iris Wipe", c, "pixel", "Ortadan büyüyen bir daireyle açar.", ["Maske", "Geçiş"], [PCT("prog", "İlerleme", 60), XY("center", "Merkez", 0, 0), J("feather", "Yumuşaklık", 0, 500, 8, 0.5, 0.2)],
   [P("GR", "Giriş", keys={"prog": [[0, 0], [0.7, 100]]}), P("CK", "Çıkış", keys={"prog": [[-0.7, 100], [0, 0]]}, at="end")])
fx("gradfade", "Geçişli Soldurma", "Gradient Fade", c, "pixel", "Katmanı bir yöne doğru yavaşça saydamlaştırır.", ["Maske", "Geçiş"], [A("ang", "Açı", 90), PCT("start", "Başlangıç", 30), PCT("end", "Bitiş", 90)])
fx("roundcorners", "Köşe Yuvarla", "Round Corners", c, "pixel", "Katmanın kutusunun köşelerini yuvarlar.", ["Maske", "Grafik"], [J("rad", "Yarıçap", 0, 500, 30, 0.5, 0.2)])
fx("shapemask", "Şekil Maske", "Shape Mask", c, "pixel", "Katmanı bir daire, kalp ya da yıldız şekline kırpar.", ["Maske", "Şekil"], [CH("shape", "Şekil", ["Daire", "Kalp", "Yıldız", "Altıgen", "Elmas"]), PCT("size", "Boyut", 90, 1, 300), J("feather", "Yumuşaklık", 0, 100, 1, 0.1, 0.05), T("inv", "Tersine çevir", 0)])

# ================= 9 Opaklık ve Görünürlük =================
c = 9
fx("flicker", "Titrek Işık", "Flicker", c, "opacity", "Bozuk lamba gibi rastgele titrer.", ["Opaklık", "Rastgele"], [PCT("amount", "Miktar", 60), J("speed", "Hız", 0.5, 60, 12, 0.5, 0.2)])
fx("blink", "Yanıp Sön", "Blink", c, "opacity", "Düzenli aralıklarla görünür ve kaybolur.", ["Opaklık"], [J("speed", "Hız", 0.1, 20, 2, 0.05, 0.02), PCT("duty", "Görünme oranı", 50)])
fx("fadein", "Belirme", "Fade In", c, "opacity", "Katmanın başında yavaşça görünür olur.", ["Opaklık", "Giriş"], [J("dur", "Süre", 0.05, 10, 0.6, 0.01, 0.01)])
fx("fadeout", "Kaybolma", "Fade Out", c, "opacity", "Katmanın sonunda yavaşça kaybolur.", ["Opaklık", "Çıkış"], [J("dur", "Süre", 0.05, 10, 0.6, 0.01, 0.01)])
fx("strobe", "Flaş", "Strobe", c, "opacity", "Hızlı açılıp kapanan flaş ışığı.", ["Opaklık", "Parti"], [J("speed", "Hız", 1, 60, 12, 0.5, 0.2)])
fx("randop", "Rastgele Opaklık", "Random Opacity", c, "opacity", "Opaklık yumuşak ve rastgele değişir.", ["Opaklık", "Rastgele"], [PCT("min", "En az", 30), PCT("max", "En çok", 100), J("speed", "Hız", 0.05, 20, 1.5, 0.05, 0.02)])
fx("breathe", "Nefes Alma", "Breathe", c, "opacity", "Opaklık yavaşça azalıp çoğalır.", ["Opaklık"], [PCT("min", "En az", 40), J("speed", "Hız", 0.05, 10, 0.5, 0.05, 0.02)])
fx("dissolve", "Piksel Çözülme", "Dissolve", c, "pixel", "Katman tek tek piksellere ayrılarak kaybolur.", ["Opaklık", "Geçiş"], [PCT("prog", "İlerleme", 50), J("size", "Tane", 1, 50, 2, 0.1, 0.05)], [P("CZ", "Çözülerek kaybol", keys={"prog": [[-0.8, 0], [0, 100]]}, at="end")])
fx("blockdissolve", "Blok Çözülme", "Block Dissolve", c, "pixel", "Katman kare bloklar hâlinde kaybolur.", ["Opaklık", "Geçiş"], [PCT("prog", "İlerleme", 50), J("size", "Blok", 2, 300, 24, 0.5, 0.2), J("seed", "Tohum", 0, 100, 1, 1, 0.2)],
   [P("BG", "Bloklarla gel", keys={"prog": [[0, 100], [0.8, 0]]})])
fx("blinds", "Jaluzi", "Venetian Blinds", c, "pixel", "Jaluzi şeritleri gibi kapanıp açılır.", ["Opaklık", "Geçiş"], [PCT("prog", "İlerleme", 40), J("count", "Şerit", 2, 60, 10, 1, 0.1), A("ang", "Açı", 0)], [P("AC", "Açılarak gel", keys={"prog": [[0, 100], [0.8, 0]]})])

# ================= 10 Metin =================
c = 10
TI = "Sadece metin katmanlarında çalışır."
fx("typewriter", "Daktilo", "Typewriter", c, "text", "Yazı harf harf yazılır gibi belirir.", ["Metin", "Animasyon"], [J("speed", "Hız (harf/sn)", 0.5, 100, 12, 0.5, 0.2), T("cursor", "İmleç", 1)], info=TI)
fx("counter", "Sayaç", "Count Up/Down", c, "text", "Yazının yerine baştan sona sayan bir sayı gösterir.", ["Metin", "Sayı"], [J("from", "Başlangıç", -1e6, 1e6, 0, 1, 0.5), J("to", "Bitiş", -1e6, 1e6, 100, 1, 0.5), J("dec", "Ondalık", 0, 3, 0, 1, 0.1), T("ease", "Yumuşak", 1)], info=TI)
fx("spacing", "Harf Aralığı", "Letter Spacing", c, "text", "Harfler arasındaki boşluğu değiştirir.", ["Metin"], [J("amount", "Aralık", -50, 300, 20, 0.5, 0.2)], [P("AC", "Açılan harfler", keys={"amount": [[0, -10], [1, 40]]})], info=TI)
fx("wavetext", "Dalgalı Yazı", "Wave Text", c, "text", "Harfler dalga gibi yukarı aşağı oynar.", ["Metin", "Animasyon"], [J("amp", "Yükseklik", 0, 200, 12, 0.5, 0.2), J("len", "Dalga boyu", 1, 30, 6, 0.1, 0.05), J("speed", "Hız", -10, 10, 1.5, 0.05, 0.02)], info=TI)
fx("scramble", "Harf Karıştır", "Scramble", c, "text", "Rastgele harflerden doğru yazıya dönüşür.", ["Metin", "Animasyon", "Hacker"], [J("dur", "Süre", 0.1, 10, 1.2, 0.01, 0.01), J("speed", "Değişim", 1, 60, 20, 0.5, 0.2)], info=TI)
fx("charfade", "Harf Harf Belirme", "Per-character Fade", c, "text", "Harfler sırayla yumuşakça belirir.", ["Metin", "Animasyon", "Giriş"], [J("stag", "Gecikme (sn)", 0.01, 1, 0.06, 0.005, 0.002), J("dur", "Belirme süresi", 0.05, 3, 0.3, 0.01, 0.01), J("rise", "Yükselme", 0, 200, 20, 0.5, 0.2)], info=TI)
fx("textbounce", "Zıplayan Harfler", "Bouncing Letters", c, "text", "Harfler sırayla zıplar.", ["Metin", "Animasyon"], [J("height", "Yükseklik", 0, 200, 20, 0.5, 0.2), J("speed", "Hız", 0.1, 10, 1.5, 0.05, 0.02)], info=TI)
fx("rainbowtext", "Gökkuşağı Yazı", "Rainbow Text", c, "text", "Her harf gökkuşağı renklerinde akar.", ["Metin", "Renk"], [J("speed", "Hız", -5, 5, 0.6, 0.01, 0.01), PCT("sat", "Doygunluk", 80)], info=TI)
fx("textshake", "Titreyen Harfler", "Jitter Letters", c, "text", "Her harf ayrı ayrı titrer.", ["Metin", "Titreşim"], [J("amount", "Miktar", 0, 50, 3, 0.1, 0.05), J("speed", "Hız", 1, 60, 12, 0.5, 0.2)], info=TI)
fx("texttransform", "Metin Dönüşümü", "Text Transform", c, "text", "Harfleri sırayla kaydırarak, döndürerek, büyüterek getirir.", ["Metin", "Animasyon", "Giriş"],
   [PCT("prog", "İlerleme", 100), J("dy", "Yükseklik", -500, 500, 60, 1, 0.5), A("rot", "Dönme", 90), PCT("scl", "Ölçek", 0, 0, 400), PCT("stag", "Sıralama", 50)],
   [P("GR", "Harf harf giriş", keys={"prog": [[0, 0], [1.2, 100]]})], info=TI)

# ================= 11 Diğer =================
c = 11
fx("copybg", "Arka Planı Kopyala", "Copy Background", c, "pixel", "Katmanın arkasındaki görüntüyü katmanın içine kopyalar; üstüne başka efekt eklersen arkaya uygulanmış olur.", ["Arka plan", "Bileşim"],
   [PCT("mix", "Karışım", 100), J("blur", "Bulanıklık", 0, 60, 0, 0.5, 0.2)], info="Buzlu cam için üstüne Gauss Bulanıklığı ekle.")
fx("posterizetime", "Kare Atla", "Posterize Time", c, "time", "Katmanın kare hızını düşürür (stop motion görünümü).", ["Zaman", "Retro"], [J("fps", "Kare/sn", 1, 60, 8, 1, 0.1)])
fx("scanlines", "Tarama Çizgileri", "Scanlines", c, "pixel", "Eski ekran gibi yatay çizgiler.", ["Retro", "Ekran"], [J("size", "Aralık", 1, 50, 4, 0.1, 0.05), PCT("op", "Koyuluk", 40), J("speed", "Kayma", -100, 100, 10, 0.5, 0.2)])
fx("grain", "Film Greni", "Film Grain", c, "pixel", "Fotoğraf filmi gibi ince ve canlı gren.", ["Retro", "Doku", "Fotoğraf"], [PCT("amount", "Miktar", 30), J("size", "Tane", 0.5, 10, 1.2, 0.05, 0.02)])
fx("vhs", "VHS", "VHS", c, "pixel", "Eski video kaseti görünümü.", ["Retro", "Glitch"], [PCT("amount", "Miktar", 60), J("speed", "Hız", 0, 10, 1, 0.05, 0.02)], pad={"add": 10})
fx("oldfilm", "Eski Film", "Old Film", c, "pixel", "Çizik, toz ve titreyen ışıkla eski sinema filmi.", ["Retro", "Sinema"], [PCT("amount", "Miktar", 70), J("speed", "Hız", 0, 30, 12, 0.5, 0.2), T("sepia", "Kahverengi", 1)])
fx("crt", "Eski Ekran", "CRT", c, "pixel", "Kavisli tüplü televizyon ekranı.", ["Retro", "Ekran"], [PCT("curve", "Kavis", 30), PCT("lines", "Çizgiler", 40), PCT("vign", "Kenar", 50)])
fx("pixelsort", "Piksel Sıralama", "Pixel Sort Streaks", c, "pixel", "Parlak bölgeleri aşağı doğru akıtır (piksel sıralama sanatı).", ["Glitch", "Sanat"], [J("len", "Uzunluk", 0, 400, 60, 0.5, 0.2), PCT("thr", "Eşik", 55), A("ang", "Açı", 90)], pad={"k": "len", "mul": 1}, heavy=True)
fx("ascii", "Yazı Sanatı", "ASCII Art", c, "pixel", "Görüntüyü küçük karakterlerden oluşan desene çevirir.", ["Retro", "Grafik", "Hacker"], [J("size", "Karakter boyu", 3, 60, 10, 0.5, 0.2), C("col", "Renk", "#22D3C5"), C("bg", "Zemin", "#0B1430"), T("orig", "Asıl renk", 0)])

order_kinds = {}
for e in E:
    for p in e["params"]:
        p["def"] = p.pop("def_")
out = dict(version=1, cats=CATS, effects=E, featured=["tiles", "chromakey", "hexarray", "glow", "cube", "fractal"])
dst = os.path.join(os.path.dirname(__file__), "../../app/src/main/assets/fx/catalog.json")
json.dump(out, open(dst, "w"), ensure_ascii=False, indent=0)
from collections import Counter
print(len(E), "efekt", Counter(CATS[e["cat"]] for e in E))
