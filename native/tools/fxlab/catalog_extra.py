# Kullanıcının sonradan verdiği tanımlar: Karton Kukla (yeni), Kesim Altlığı (yeni), Dokulandır (güncel).
# Ortak malzeme kütüphanesi: assets/fx/_mat.glsl. Ayarlar panelde gruplar ("g") hâlinde; "vis" = yalnız seçili malzemede görünür.
def _u(p, unit="", g=None, anim="yes", vis=None, **kw):
    p = dict(p); p["unit"] = unit; p["anim"] = anim
    if g: p["g"] = g
    if vis: p["vis"] = vis
    p.update(kw); return p
def PC(k, l, d, mn=0, mx=100, g=None, vis=None): return _u(J(k, l, mn, mx, d, 0.1, 0.1), "%", g, vis=vis)
def PX(k, l, d, mn=0, mx=50, g=None, vis=None): return _u(J(k, l, mn, mx, d, 0.1, 0.1), "px", g, vis=vis)
def DG(k, l, d, mn=-180, mx=180, g=None, vis=None): return _u(J(k, l, mn, mx, d, 0.1, 0.1), "°", g, vis=vis)
def TG(k, l, d, g=None, vis=None): return _u(T(k, l, d), "", g, anim="step", vis=vis)
def CS(k, l, opts, d=0, g=None, vis=None): return _u(CH(k, l, opts, d), "", g, anim="step", vis=vis)
def CL(k, l, d, g=None, vis=None): return _u(C(k, l, d), "", g, vis=vis)
def IN(k, l, d, mn, mx, unit="", g=None, vis=None): return _u(J(k, l, mn, mx, d, 1, 1), unit, g, int=True)
def SRC(k, l, g=None, vis=None): return dict(k=k, l=l, kind="source", min=0, max=0, def_="", step=1, jog=1, anim="no", g=g, hint="Görsel / katman", **({"vis": vis} if vis else {}))

# Malzeme şablonları (Kesim Altlığı dolgusu: tam liste)
MAT_FULL = ["Düz renk", "Geçiş", "Beyaz kâğıt", "Renkli kâğıt", "Karton", "Oluklu karton", "Mukavva", "Kraft kâğıt", "Buruşturulmuş kâğıt", "Yırtılmış kâğıt",
            "Eski parşömen", "Keçe", "Kumaş", "Ahşap", "Plastik", "Metal", "Çıkartma", "Köpük", "Özel doku"]
def matSpecific(key, g):
    v = lambda *names: {"k": key, "in": [MAT_FULL.index(n) for n in names]}
    return [PX("olukGeni", "Oluk genişliği", 6, 1, 40, g, v("Oluklu karton")), PC("olukDerin", "Oluk derinliği", 50, g=g, vis=v("Oluklu karton")), DG("olukYon", "Oluk yönü", 0, g=g, vis=v("Oluklu karton")),
            PX("kirisBuyu", "Kırışıklık büyüklüğü", 40, 5, 200, g, v("Buruşturulmuş kâğıt")), PC("kirisDerin", "Kırışıklık derinliği", 55, g=g, vis=v("Buruşturulmuş kâğıt")), PC("kirisYogun", "Kırışıklık yoğunluğu", 50, g=g, vis=v("Buruşturulmuş kâğıt")),
            PX("yirtikDerin", "Yırtık derinliği", 8, 0, 50, g, v("Yırtılmış kâğıt")), PX("lifUzun", "Kenar lifi uzunluğu", 4, 0, 30, g, v("Yırtılmış kâğıt")),
            PX("damarGeni", "Damar genişliği", 8, 1, 40, g, v("Ahşap")), DG("damarYon", "Damar yönü", 0, g=g, vis=v("Ahşap")),
            PX("tuyUzun", "Tüy uzunluğu", 4, 0, 20, g, v("Keçe")), PC("tuyYogun", "Tüy yoğunluğu", 60, g=g, vis=v("Keçe")),
            PC("yansimaGuc", "Yansıma gücü", 60, g=g, vis=v("Metal")), PC("metalik", "Metalik görünüm", 80, g=g, vis=v("Metal")),
            PC("eskime", "Eskime", 50, g=g, vis=v("Eski parşömen")), PC("sararma", "Sararma", 60, g=g, vis=v("Eski parşömen")), PC("leke", "Leke yoğunluğu", 35, g=g, vis=v("Eski parşömen"))]
def matCommon(key, g, defTex=35):
    return [PC("dokuGucu", "Doku gücü", defTex, g=g), PC("dokuOlcek", "Doku ölçeği", 100, 10, 500, g), DG("dokuAci", "Doku açısı", 0, 0, 360, g),
            _u(XY("dokuKonum", "Doku konumu", 0, 0, -1000, 1000, 0.1), "px", g), CL("malzRenk", "Malzeme rengi", "#C9A57A", g), TG("dogalRenk", "Doğal rengi koru", 1, g),
            PC("malzOpak", "Malzeme opaklığı", 100, g=g), PX("yuzeyYuks", "Yüzey yükseltisi", 4, 0, 50, g), PC("puruz", "Yüzey pürüzlülüğü", 40, g=g),
            PC("parlak", "Yüzey parlaklığı", 12, g=g), PC("lif", "Lif belirginliği", 30, g=g), PC("kenarAsin", "Kenar aşınması", 15, g=g),
            PX("malzKalin", "Malzeme kalınlığı", 3, 0, 50, g), TG("sekleSabit", "Dokuyu şekle sabitle", 1, g), SRC("ozelDoku", "Özel doku", g, {"k": key, "in": [MAT_FULL.index("Özel doku")]})]

EDGE = ["Düzgün", "Yuvarlak", "Çokgen", "Makas Kesimi", "Yırtık", "El Kesimi"]
def shadowGroup(g, dist, soft, op):
    return [TG("golgeAcik", "İçerik gölgesi", 1, g), DG("golgeAci", "Gölge açısı", 135, 0, 360, g), PX("golgeUzak", "Gölge uzaklığı", dist, 0, 50, g),
            PX("golgeYumu", "Gölge yumuşaklığı", soft, 0, 50, g), PC("golgeOpak", "Gölge opaklığı", op, g=g), CL("golgeRenk", "Gölge rengi", "#3A302A", g)]
def dynGroup(g, change, unst, mem):
    return [CS("kenarDavr", "Kenar davranışı", ["Sabit", "Dinamik"], 1, g), IN("yenilenme", "Yenilenme aralığı", 3, 1, 24, " kare", g),
            PC("kenarDegis", "Kenar değişim gücü", change, g=g), PC("kenarKarars", "Kenar kararsızlığı", unst, g=g), PC("bicimHafiza", "Biçim hafızası", mem, g=g)]

# ---------- Kesim Altlığı ----------
G1, G2, G3, G4, G5, G6 = "Siluet", "Konum", "Kenar", "Dolgu", "Gölge", "Dinamik Takip"
fx("cutback", "Kesim Altlığı", "Cutout Backing", 1, "pixel", "Katmanın siluetinden arkasında duran kalın bir altlık üretir; makasla kesilmiş karton, çıkartma ya da el işi malzemesi gibi görünür ve katmanı her harekette takip eder.",
   ["Kenar", "Karton", "Çıkartma", "Countryball", "Malzeme"],
   [PX("kalinlik", "Kalınlık", 18, 0, 100, G1), TG("disaBuyut", "Sadece dışa büyüt", 1, G1), CS("alfaYorum", "Alfa yorumu", ["Sert", "Yumuşak", "Ağırlıklı", "Eşiğe Göre"], 2, G1),
    PC("alfaEsik", "Alfa eşiği", 35, g=G1, vis={"k": "alfaYorum", "in": [3]}), PC("kusursuz", "Kusursuzluk", 82, g=G1), PC("basitles", "Siluet basitleştirme", 12, g=G1),
    TG("delikKapat", "Küçük delikleri kapat", 1, G1), TG("inceKoru", "İnce çıkıntıları koru", 1, G1),
    PX("ofsX", "Ofset X", -8, -100, 100, G2), PX("ofsY", "Ofset Y", 8, -100, 100, G2), TG("birlikteDondur", "Katmanla birlikte döndür", 1, G2), TG("birlikteOlcek", "Katmanla birlikte ölçekle", 1, G2),
    CS("kenarStili", "Kenar stili", EDGE, 3, G3), PC("kenarSert", "Kenar sertliği", 55, g=G3), PC("koseYumu", "Köşe yumuşaklığı", 28, g=G3), PC("kenarGurultu", "Kenar gürültüsü", 18, g=G3), PC("cokgen", "Çokgenleşme", 20, g=G3),
    CS("dolguTuru", "Malzeme şablonu", MAT_FULL, 4, G4), CL("ikinciRenk", "İkinci renk", "#8A6A48", G4, {"k": "dolguTuru", "in": [1]})] + matCommon("dolguTuru", G4) + matSpecific("dolguTuru", G4)
   + shadowGroup(G5, 6, 10, 38)
   + [TG("sekliTakip", "Şekli takip et", 1, G6), TG("donusumTakip", "Dönüşümü takip et", 1, G6)] + dynGroup(G6, 18, 12, 82)
   + [IN("takipGecik", "Takip gecikmesi", 0, 0, 12, " kare", G6), PC("esneklik", "Altlık esnekliği", 0, g=G6), IN("kenarTohum", "Kenar tohumu", 1, 0, 9999, "", G6), TG("tohumCanl", "Tohumu canlandır", 1, G6)],
   pad={"sum": ["kalinlik", "golgeUzak"], "mul": 1.2, "add": 12})
E[-1]["n"] = 431

# ---------- Karton Kukla ----------
K0, K1, K2, K3, K4, K5 = "Genel", "Ana Doku", "Altlık", "Kenar Canlılığı", "Gölge ve Derinlik", "Kukla Animasyon"
TOP = ["Karton", "Oluklu Karton", "Kraft Kağıt", "Mukavva", "Buruşturulmuş Kağıt", "Kağıt", "Özel Doku"]
BACK = ["Karton", "Oluklu Karton", "Kraft Kağıt", "Mukavva", "Buruşturulmuş Kağıt", "Düz Renk", "Özel Doku"]
fx("cardpuppet", "Karton Kukla", "Cardboard Puppet", 16, "pixel", "Katmanı karton kukla görünümüne çevirir: üstüne karton/kâğıt dokusu, arkasına makasla kesilmiş altlık, istersen stop-motion kukla hissi. Countryball ve çıkartma animasyonları için.",
   ["Countryball", "Karton", "Kukla", "Stop-motion", "Malzeme"],
   [PC("orijKoru", "Orijinali koru", 0, g=K0),
    CS("dokuTuru", "Doku türü", TOP, 0, K1), PC("dokuGucu", "Doku gücü", 42, g=K1), PC("dokuOlcek", "Doku ölçeği", 100, 25, 400, K1), DG("dokuAci", "Doku açısı", 0, g=K1),
    PC("dokuOpak", "Doku opaklığı", 65, g=K1), PC("dokuKontrast", "Doku kontrastı", 10, -100, 100, K1), PC("dokuParlak", "Doku parlaklığı", 0, -100, 100, K1),
    PX("kabarti", "Kabartı gücü", 6, 0, 50, K1), PC("lif", "Lif belirginliği", 35, g=K1), TG("renkleBirles", "Renkle birleştir", 1, K1), SRC("ozelDoku", "Özel doku dosyası", K1, {"k": "dokuTuru", "in": [6]}),
    TG("altlikAcik", "Altlığı etkinleştir", 1, K2), PX("kalinlik", "Altlık kalınlığı", 16, 0, 100, K2), PX("ofsX", "Altlık ofset X", -6, -100, 100, K2), PX("ofsY", "Altlık ofset Y", 7, -100, 100, K2),
    CS("altlikDoku", "Altlık doku türü", BACK, 0, K2), CL("altlikRenk", "Altlık rengi", "#C9A57A", K2), PC("altlikDokuGuc", "Altlık doku gücü", 35, g=K2), PX("altlikKabarti", "Altlık kabartısı", 4, 0, 50, K2),
    SRC("altlikOzel", "Altlık özel doku", K2, {"k": "altlikDoku", "in": [6]}), TG("disaBuyut", "Sadece dışa büyüt", 1, K2),
    CS("kenarStili", "Kenar stili", EDGE, 3, K3), PC("kusursuz", "Kusursuzluk", 78, g=K3), PC("takipSadakat", "Takip sadakati", 88, g=K3), PC("kenarSert", "Kenar sertliği", 52, g=K3),
    PC("koseYumu", "Köşe yumuşaklığı", 22, g=K3)] + dynGroup(K3, 14, 10, 84) + [IN("kenarTohum", "Kenar tohumu", 1, 0, 9999, "", K3), TG("tohumCanl", "Tohumu canlandır", 1, K3)]
   + shadowGroup(K4, 5, 9, 36)
   + [TG("stopMotion", "Stop-motion hissi", 0, K5), IN("kuklaFps", "Kukla kare hızı", 12, 4, 24, " FPS", K5), PC("eklemSert", "Eklemlerde hafif sertlik", 28, g=K5), PC("mikroSallan", "Mikro sallanma", 8, g=K5)],
   [P("CB", "CB Karton"),
    P("OP", "Okul Projesi", {"dokuTuru": 5, "dokuGucu": 30, "altlikDoku": 5, "kalinlik": 10, "kenarStili": 5, "kusursuz": 60, "stopMotion": 1, "kuklaFps": 10}, cols={"altlikRenk": "#FFFFFF"}),
    P("KC", "Komik Çıkartma", {"dokuGucu": 15, "altlikDoku": 5, "kalinlik": 14, "ofsX": 0, "ofsY": 4, "kenarStili": 1, "kusursuz": 95, "kenarDavr": 0}, cols={"altlikRenk": "#FFFFFF"}),
    P("SM", "Sert Mukavva", {"dokuTuru": 3, "dokuGucu": 60, "altlikDoku": 3, "kalinlik": 20, "kabarti": 10, "kenarStili": 2, "kusursuz": 70}),
    P("YK", "Yumuşak Kağıt", {"dokuTuru": 4, "dokuGucu": 35, "altlikDoku": 4, "kalinlik": 12, "kenarStili": 1, "koseYumu": 60}),
    P("EK", "El Kesimi", {"kenarStili": 5, "kusursuz": 55, "kenarKarars": 25, "kenarDegis": 30, "stopMotion": 1, "kuklaFps": 8})],
   pad={"sum": ["kalinlik", "golgeUzak"], "mul": 1.2, "add": 12})
E[-1]["n"] = 432

# ---------- Dokulandır (güncel; aynı kütüphane) ----------
TEX = ["Tuval", "Kağıt", "Karton", "Oluklu Karton", "Kraft Kağıt", "Mukavva", "Buruşturulmuş Kağıt", "Tuğla", "Beton", "Ahşap", "Keçe", "İnce Bez", "Geri Dönüşüm Kağıdı", "Özel Doku"]
D2, D3, D4, D5 = "Doku Kaynağı", "Doku Görünümü", "Yüzey Derinliği", "Renk ve Karışım"
_tz = next(e for e in E if e["type"] == "texturize")
_tz["params"] = [CS("dokuTuru", "Doku türü", TEX, 0, D2), SRC("ozelDoku", "Özel doku dosyası", D2, {"k": "dokuTuru", "in": [13]}), IN("dokuTohum", "Doku tohumu", 1, 0, 9999, "", D2),
    PC("dokuGucu", "Doku gücü", 50, g=D3), PC("dokuOlcek", "Doku ölçeği", 100, 10, 500, D3), DG("dokuAci", "Doku açısı", 45, g=D3),
    PX("kaydirX", "Doku kaydırma X", 0, -1000, 1000, D3), PX("kaydirY", "Doku kaydırma Y", 0, -1000, 1000, D3), TG("tekrar", "Doku tekrarı", 1, D3), PC("dikisGizle", "Dikiş gizleme", 25, g=D3),
    PX("kabartma", "Kabartma", 3, 0, 50, D4), DG("kabartmaAci", "Kabartma açısı", 135, 0, 360, D4), PC("kabartmaYogun", "Kabartma yoğunluğu", 35, g=D4), PC("lif", "Lif belirginliği", 20, g=D4), PC("buruskluk", "Buruşukluk gücü", 0, g=D4),
    TG("renkleBirles", "Renkle birleştir", 1, D5), CL("dokuRenk", "Doku rengi", "#FFFFFF", D5), PC("dokuOpak", "Doku opaklığı", 100, g=D5), TG("tersDoku", "Ters doku", 0, D5),
    TG("sadeceAydin", "Sadece aydınlığa uygula", 0, D5), TG("sadeceGolge", "Sadece gölgelere uygula", 0, D5)]
_tz["presets"] = [P("KR", "Karton", {"dokuTuru": 2, "dokuGucu": 60, "kabartma": 5}), P("KK", "Kraft Kağıt", {"dokuTuru": 4, "dokuGucu": 65, "lif": 60}),
                  P("BK", "Buruşturulmuş Kâğıt", {"dokuTuru": 6, "dokuGucu": 70, "kabartma": 8, "buruskluk": 60}), P("AH", "Ahşap", {"dokuTuru": 9, "dokuGucu": 60}),
                  P("AN", "Animasyonlu", keys={"dokuGucu": [[0, 0], [0.5, 80], [1, 0]]})]
_tz["desc"] = "Katmanın yüzeyine kâğıt, karton, kumaş, tuval gibi dokular uygular; görüntüyü malzeme hissi taşıyan bir yüzeye çevirir."
_tz["pad"] = None; _tz["passes"] = None
