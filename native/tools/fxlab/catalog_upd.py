# "Efekt Kütüphanesi Genişletme ve Güncelleme Talimatı" — Bölüm A: mevcut efektlere eklenen ayarlar.
# Var olan ayarlar korunur; yeni ayarlar eskilerin arkasına, gruplar hâlinde eklenir ve eski projelerde etkisiz başlar.
_BY = {e["type"]: e for e in E}
def ADD(t, params, presets=None, replace_presets=False):
    e = _BY[t]; have = {p["k"] for p in e["params"]}
    for p in params:
        if p["k"] not in have: e["params"].append(p); have.add(p["k"])
    if presets:
        e["presets"] = presets + [x for x in e["presets"] if x.get("alias") or x.get("auto")]
def OPTS(t, k, opts):  # mevcut seçim ayarına seçenek ekle (eski indeksler korunur)
    p = next(p for p in _BY[t]["params"] if p["k"] == k)
    for o in opts:
        if o not in p["opts"]: p["opts"].append(o)
    p["max"] = len(p["opts"]) - 1
def RANGE(t, k, mn=None, mx=None):
    p = next(p for p in _BY[t]["params"] if p["k"] == k)
    if mn is not None: p["min"] = mn
    if mx is not None: p["max"] = mx
def WHEEL(k, l, hk, sk, g): return dict(k=k, l=l, kind="wheel", min=0, max=0, def_=0, step=1, jog=1, anim="no", g=g, hk=hk, sk=sk)
def BTN(k, l, reset, g=None, vis=None): return dict(k=k, l=l, kind="button", min=0, max=0, def_=0, step=1, jog=1, anim="no", g=g, reset=reset, **({"vis": vis} if vis else {}))
def XYP(k, l, dx, dy, mn, mx, unit="px", g=None, vis=None, link=False): return _u(XY(k, l, dx, dy, mn, mx, 0.1), unit, g, vis=vis, link=link)
def EGRI(k, l, g=None, vis=None): return dict(k=k, l=l, kind="curve", min=0, max=1, def_=[[0, 0], [1, 1]], step=1, jog=1, anim="no", g=g, **({"vis": vis} if vis else {}))
def LAY(k, l, g=None, vis=None): return SRC(k, l, g, vis)

# 5 Renk Ayarı — gelişmiş mod: dört renk çarkı
GA = "Gelişmiş Renk Düzenleme"; vA = {"k": "duzenMod", "in": [1]}
_cw = []
for key, nm in [("golge", "Gölgeler"), ("orta", "Orta tonlar"), ("acik", "Açık tonlar"), ("genel", "Genel")]:
    _cw += [WHEEL(key + "Cark", nm + " renk çarkı", key + "Yon", key + "Guc", GA), DG(key + "Yon", nm + " · renk yönü", 0, 0, 360, GA, vA), PC(key + "Guc", nm + " · renk gücü", 0, g=GA, vis=vA),
            PC(key + "Parlak", nm + " · parlaklık", 0, -100, 100, GA, vA), BTN(key + "Sifirla", nm + " çarkını sıfırla", [key + "Yon", key + "Guc", key + "Parlak"], GA, vA)]
for p in _cw:
    if p["kind"] == "wheel": p["vis"] = vA
ADD("colortune", [CS("duzenMod", "Düzenleme modu", ["Basit", "Gelişmiş"], 0, GA)] + _cw + [TG("parlakKoruG", "Orijinal parlaklığı koru", 0, GA, vA), TG("tasmaSinir", "Renk taşmalarını sınırla", 1, GA, vA)],
    [P("SN", "Sinematik", {"duzenMod": 1, "golgeYon": 190, "golgeGuc": 35, "acikYon": 30, "acikGuc": 30}), P("SC", "Sıcak atmosfer", {"duzenMod": 1, "genelYon": 30, "genelGuc": 30}),
     P("SG", "Soğuk atmosfer", {"duzenMod": 1, "genelYon": 210, "genelGuc": 30}), P("PS", "Pastel", {"duzenMod": 1, "golgeParlak": 30, "genelGuc": 15, "genelYon": 300}),
     P("TR", "Tarihi görüntü", {"duzenMod": 1, "golgeYon": 30, "golgeGuc": 40, "acikYon": 45, "acikGuc": 25, "genelParlak": -5}), P("DG", "Doğal renk", {"duzenMod": 1})], True)

# 14 Geçiş Haritası
G14 = "Gelişmiş"
ADD("gradmap", [CS("gecisBicim", "Geçiş biçimi", ["Doğrusal", "Yumuşak", "Keskin"], 0, G14), CS("haritaKayn", "Harita kaynağı", ["Parlaklık", "Kırmızı", "Yeşil", "Mavi", "Alfa"], 0, G14),
    PC("gecisKontrast", "Geçiş kontrastı", 100, 0, 300, G14), TG("parlakKoru", "Orijinal parlaklığı koru", 0, G14), TG("alfaKoru", "Alfa kanalını koru", 1, G14)],
    [P("IR", "İki renk", cols={"renkGeci": '[["#1B2A55",0],["#F2C230",100]]'}), P("UR", "Üç renk", cols={"renkGeci": '[["#0B1430",0],["#E84393",50],["#F7F8FA",100]]'}),
     P("TK", "Termal kamera", cols={"renkGeci": '[["#000010",0],["#3B0A7A",25],["#C2185B",50],["#FF8F00",75],["#FFFDE7",100]]'}),
     P("GK", "Gökkuşağı", cols={"renkGeci": '[["#E30A17",0],["#FF9800",20],["#FFEB3B",40],["#4CAF50",60],["#2196F3",80],["#8E24AA",100]]'}),
     P("GG", "Gece görüşü", cols={"renkGeci": '[["#001500",0],["#1B8F1B",55],["#C8FFC8",100]]'}), P("SP", "Sepya", cols={"renkGeci": '[["#2B1A0E",0],["#9B6B43",55],["#F3E3C3",100]]'})], True)

# 58 Parlama
G58 = "Kaynak ve Hale"
ADD("glow", [CS("kaynakTur", "Parlama kaynağı", ["Alfa", "Parlaklık", "Renk", "Özel maske"], 0, G58), LAY("ozelMaske", "Özel maske", G58, {"k": "kaynakTur", "in": [3]}),
    PC("esik", "Parlaklık eşiği", 50, g=G58, vis={"k": "kaynakTur", "in": [1, 2]}), PC("esikYumu", "Eşik yumuşaklığı", 20, g=G58, vis={"k": "kaynakTur", "in": [1, 2]}),
    CL("icRenk", "İç hale rengi", "#FFFFFF", G58), CL("disRenk", "Dış hale rengi", "#53A8FF", G58), PX("icBuyu", "İç hale büyüklüğü", 0, 0, 200, G58), PX("disBuyu", "Dış hale büyüklüğü", 0, 0, 500, G58),
    PC("icGuc", "İç hale gücü", 80, 0, 200, G58), PC("disGuc", "Dış hale gücü", 40, 0, 200, G58), TG("kaynakRenk", "Kaynak renklerinden parlama üret", 0, G58)],
    [P("NE", "Neon", {"yaricap": 30, "icBuyu": 4, "disBuyu": 30, "icGuc": 120, "disGuc": 70}, cols={"icRenk": "#FFFFFF", "disRenk": "#22D3C5", "renk": "#22D3C5"}),
     P("YI", "Yumuşak ışık", {"yaricap": 50, "yogunluk": 45}, cols={"renk": "#FFF3D0"}), P("EN", "Enerji", {"yaricap": 25, "icBuyu": 6, "disBuyu": 45, "disGuc": 90}, cols={"disRenk": "#8F7CF0", "icRenk": "#E0D8FF"}),
     P("AT", "Ateş", {"yaricap": 35, "icBuyu": 5, "disBuyu": 40, "disGuc": 80}, cols={"icRenk": "#FFE08A", "disRenk": "#FF4400", "renk": "#FF6A00"}),
     P("BZ", "Buz", {"yaricap": 30, "icBuyu": 3, "disBuyu": 35}, cols={"icRenk": "#FFFFFF", "disRenk": "#9AD8FF", "renk": "#BFE9FF"}),
     P("RK", "Renkli kontur", {"yaricap": 12, "kaynakRenk": 1, "yogunluk": 90})], True)

# 60 Kontur
G60 = "Gelişmiş Kontur"
ADD("stroke", [CS("dolgu", "Kontur dolgusu", ["Düz renk", "Renk geçişi", "Doku"], 0, G60), CL("renk2g", "Geçiş ikinci rengi", "#2F7BF6", G60, {"k": "dolgu", "in": [1]}),
    PX("ikinciKalin", "İkinci kontur kalınlığı", 0, 0, 300, G60), CL("ikinciRenk", "İkinci kontur rengi", "#FFFFFF", G60), CS("cizgiBicim", "Çizgi biçimi", ["Sürekli", "Kesikli", "Noktalı"], 0, G60),
    PX("kesikUzun", "Kesik uzunluğu", 10, 1, 300, G60, {"k": "cizgiBicim", "in": [1, 2]}), PX("kesikBosluk", "Kesik boşluğu", 5, 0, 300, G60, {"k": "cizgiBicim", "in": [1, 2]}),
    PX("cizgiFaz", "Çizgi fazı", 0, -1000, 1000, G60, {"k": "cizgiBicim", "in": [1, 2]}), CS("alfaYorum", "Alfa yorumu", ["Sert", "Yumuşak", "Ağırlıklı", "Eşiğe göre"], 2, G60),
    PC("alfaEsik", "Alfa eşiği", 35, g=G60, vis={"k": "alfaYorum", "in": [3]}), TG("delikKontur", "İç deliklerin çevresine kontur uygula", 1, G60), TG("ekranSabit", "Kontur kalınlığını ekranda sabit tut", 0, G60)],
    [P("CK", "Çift kontur", {"kalinlik": 6, "ikinciKalin": 6}, cols={"renk": "#111111", "ikinciRenk": "#FFFFFF"}), P("NC", "Neon çizgi", {"kalinlik": 4}, cols={"renk": "#22D3C5"}),
     P("CF", "Çizgi film", {"kalinlik": 8}, cols={"renk": "#111111"}), P("HS", "Harita sınırı", {"kalinlik": 3, "konum": 2}, cols={"renk": "#F7F8FA"}),
     P("KS", "Kesikli sınır", {"kalinlik": 3, "cizgiBicim": 1, "kesikUzun": 12, "kesikBosluk": 6}, cols={"renk": "#F7F8FA"})], True)

# 69 Pürüzlü Kenar
G69 = "Kenar Biçimi ve Dinamik"
ADD("roughen", [CS("kenarBicim", "Kenar biçimi", ["Yırtık", "Makas kesimi", "Çokgen", "Dalgalı", "Pürüzlü", "El çizimi"], 4, G69), PC("cokgen", "Çokgenleşme", 20, g=G69),
    PC("koseYumu", "Köşe yumuşaklığı", 20, g=G69), PC("kenarSert", "Kenar sertliği", 70, g=G69), TG("dinamik", "Dinamik kenarlar", 0, G69),
    IN("yenilenme", "Yenilenme aralığı", 3, 1, 120, " kare", G69), PC("degisim", "Değişim gücü", 15, g=G69, vis={"k": "dinamik", "in": [1]}), PC("hafiza", "Biçim hafızası", 80, g=G69, vis={"k": "dinamik", "in": [1]}),
    TG("anaSiluet", "Ana silueti koru", 1, G69)])

# 76 Dokulandır: talimattaki malzeme listesi (eski indeksler korunur, yeniler sona)
OPTS("texturize", "dokuTuru", ["Beyaz kâğıt", "Renkli kâğıt", "Yırtılmış kâğıt", "Parşömen", "Kumaş", "Taş", "Metal", "Plastik", "Deri görünümü", "Kum"])
_tz = _BY["texturize"]
for p in _tz["params"]:
    if p["k"] == "ozelDoku": p["vis"] = {"k": "dokuTuru", "in": [13]}
D3, D4, D5 = "Doku Görünümü", "Yüzey Derinliği", "Renk ve Karışım"
ADD("texturize", [XYP("dokuKaydir", "Doku kaydırma", 0, 0, -4000, 4000, "px", D3), PC("dokuKontrast", "Doku kontrastı", 0, -100, 100, D3), PC("dokuParlak", "Doku parlaklığı", 0, -100, 100, D3),
    PC("puruzluluk", "Yüzey pürüzlülüğü", 50, g=D4), PC("yuzeyParlak", "Yüzey parlaklığı", 10, g=D4),
    TG("alfaKoru", "Alfa sınırlarını koru", 1, D5), TG("nesneSabit", "Dokuyu nesneye sabitle", 1, D5), TG("esnet", "Şekil değişiminde dokuyu esnet", 1, D5), TG("dogalRenk", "Doğal malzeme rengini kullan", 0, D5),
    PX("olukGeni", "Oluk genişliği", 6, 1, 40, "Malzeme Ayarları", {"k": "dokuTuru", "in": [3]}), PC("olukDerin", "Oluk derinliği", 50, g="Malzeme Ayarları", vis={"k": "dokuTuru", "in": [3]}),
    DG("olukYon", "Oluk yönü", 0, g="Malzeme Ayarları", vis={"k": "dokuTuru", "in": [3]}), PX("kirisBuyu", "Kırışıklık büyüklüğü", 40, 5, 200, "Malzeme Ayarları", {"k": "dokuTuru", "in": [6]}),
    PC("kirisYogun", "Kırışıklık yoğunluğu", 50, g="Malzeme Ayarları", vis={"k": "dokuTuru", "in": [6]}), PX("damarGeni", "Damar genişliği", 8, 1, 40, "Malzeme Ayarları", {"k": "dokuTuru", "in": [9]})])
for p in _tz["params"]:
    if p["k"] == "renkleBirles": p["l"] = "Orijinal renkleri koru"

# 103 Gauss Bulanıklığı
G103 = "Eksenler ve Alan"
ADD("blur", [XYP("xyYari", "Yatay ve dikey bulanıklık", 0, 0, 0, 500, "px", G103, link=True), TG("eksenBagla", "Eksenleri birbirine bağla", 1, G103),
    CS("alan", "Bulanıklık alanı", ["Tüm katman", "Alfa", "Özel maske", "Parlaklık"], 0, G103), LAY("maske", "Maske katmanı", G103, {"k": "alan", "in": [2]}),
    TG("maskeTers", "Maskeyi ters çevir", 0, G103), CS("kalite", "Kalite", ["Otomatik", "Düşük", "Orta", "Yüksek"], 0, G103), TG("koyuKenarOnle", "Saydam kenarlarda koyu renk oluşmasını önle", 1, G103)])

# 137 Dalga Bükme
OPTS("wave", "dalgaTipi", ["Testere dişi", "Düzensiz", "Özel eğri"])
G137 = "İkinci Dalga ve Döngü"
ADD("wave", [EGRI("ozelEgri", "Özel dalga eğrisi", G137, {"k": "dalgaTipi", "in": [5]}), PC("yayilim", "Dalga yayılımı", 100, g=G137), TG("konumaGore", "Dalga yüksekliğini konuma göre değiştir", 0, G137),
    EGRI("yukDagilim", "Dalga yüksekliği dağılımı", G137, {"k": "konumaGore", "in": [1]}), PC("ikinciGuc", "İkinci dalga gücü", 0, g=G137), PX("ikinciBoy", "İkinci dalga boyu", 60, 1, 1000, G137),
    _u(J("ikinciHiz", "İkinci dalga hızı", 0, 30, 0.5, 0.01, 0.01), "Hz", G137), PC("sonum", "Sönümlenme", 0, g=G137), TG("dongu", "Kusursuz döngü", 0, G137),
    _u(J("donguSure", "Döngü süresi", 0.1, 60, 2, 0.01, 0.01), "s", G137, vis={"k": "dongu", "in": [1]})])
RANGE("wave", "dalgaBoyu", 1, 1000)

# 144 Panel Döşeme
G144 = "Izgara"
ADD("tiles", [CS("bicim", "Döşeme biçimi", ["Kare", "Dikdörtgen", "Tuğla", "Baklava"], 0, G144), XYP("karoOran", "Karo oranı", 100, 100, 1, 1000, "%", G144, link=True),
    DG("izgaraAci", "Izgaranın genel açısı", 0, -360, 360, G144), CS("alanT", "Tekrar alanı", ["Katman sınırı", "Proje sınırı", "Özel alan"], 1, G144),
    TG("yAyna", "Yatay aynalama", 0, G144), TG("dAyna", "Dikey aynalama", 0, G144), TG("disPiksel", "Ekran dışındaki kaynak pikselleri kullan", 1, G144),
    TG("dikisGizle", "Dikişleri gizle", 1, G144), PX("dikisYumu", "Dikiş yumuşaklığı", 0, 0, 30, G144)])

# 154 Renk Kayması
G154 = "Ayrışma"
ADD("rgbsplit", [CS("ayrBicim", "Ayrışma biçimi", ["Doğrusal", "Radyal", "Dönel"], 0, G154), _u(XY("radMerkez", "Radyal merkez", 50, 50, -100, 200, 0.1), "box%", G154, vis={"k": "ayrBicim", "in": [1, 2]}),
    PC("uzakAyr", "Merkezden uzaklaştıkça ayrışma", 100, 0, 200, G154, {"k": "ayrBicim", "in": [1, 2]}), PC("rOpak", "Kırmızı kanal opaklığı", 100, g=G154), PC("gOpak", "Yeşil kanal opaklığı", 100, g=G154),
    PC("bOpak", "Mavi kanal opaklığı", 100, g=G154), TG("alfaSinir", "Orijinal alfa sınırını koru", 0, G154)])

# 155 Bozuk Sinyal
G155 = "Bozulma Türü ve Tetikleme"
ADD("glitch", [CS("tur", "Bozulma türü", ["Dijital", "Analog", "Blok", "Çizgi", "Veri bozulması"], 0, G155), PC("yatayOran", "Yatay blok oranı", 100, 1, 1000, G155), PC("dikeyOran", "Dikey blok oranı", 100, 1, 1000, G155),
    _u(J("siklik", "Bozulma sıklığı", 0, 20, 0, 0.01, 0.01), "Hz", G155), _u(J("sure", "Bozulma süresi", 0, 5, 0.1, 0.01, 0.01), "s", G155), PC("renkKayip", "Renk örnekleme kaybı", 0, g=G155),
    TG("elle", "Bozulmaları elle tetikle", 0, G155), PC("tetikGuc", "Tetikleme gücü", 0, g=G155, vis={"k": "elle", "in": [1]}), TG("parlakSinir", "Ani parlaklık değişimlerini sınırla", 1, G155)])

# 156 Türbülanslı Yer Değiştirme
G156 = "Türbülans"
ADD("displace", [XYP("turbOlcek", "Türbülans ölçeği", 100, 100, 1, 1000, "%", G156, link=True), TG("eksenBagla", "Eksenleri bağla", 1, G156), DG("turbYon", "Türbülans yönü", 0, 0, 360, G156),
    XYP("paralaks", "Paralaks kayması", 0, 0, -4000, 4000, "px", G156), PC("kenarKoru", "Kenar koruma gücü", 0, g=G156), _u(J("evrimHiz", "Evrim hızı", -3600, 3600, 0, 0.1, 0.1), "°/sn", G156),
    TG("dongu", "Kusursuz evrim döngüsü", 0, G156), _u(J("donguSure", "Döngü süresi", 0.1, 60, 3, 0.01, 0.01), "s", G156, vis={"k": "dongu", "in": [1]})])

# 173 Yer Değiştirme Haritası
G173 = "Hedef ve Harita"
ADD("dispmap", [CS("etkiAlan", "Etkilenen alan", ["Mevcut katman", "Arka plan", "Seçilen katman"], 0, G173), LAY("hedefKatm", "Etkilenecek katman", G173, {"k": "etkiAlan", "in": [2]}),
    TG("haritaGorunur", "Harita katmanını görünür tut", 0, G173), TG("merkezden", "Merkezden hesapla", 0, G173), PC("notr", "Nötr harita değeri", 50, g=G173),
    CS("birim", "Miktar birimi", ["Yüzde", "Piksel"], 0, G173), PX("haritaYumu", "Harita yumuşatma", 0, 0, 100, G173), PC("haritaKontrast", "Harita kontrastı", 100, 0, 300, G173),
    TG("hedefUyar", "Haritayı hedefe uyarla", 1, G173), CS("yerlesim", "Harita yerleşimi", ["Kapla", "Sığdır", "Döşe", "Orijinal boyut"], 0, G173)])

# 182 Omino Cam
GY, GI = "Yüzey", "Işık"
ADD("ominoglass", [CS("yukKayn", "Yükseklik kaynağı", ["Omino karolar", "Katman parlaklığı", "Alfa", "Özel harita"], 0, GY), PC("pah", "Kenar pahı", 10, g=GY), PC("puruz", "Yüzey pürüzlülüğü", 0, g=GY),
    PC("puruzOlcek", "Pürüz ölçeği", 100, 1, 1000, GY), DG("puruzEvrim", "Pürüz evrimi", 0, -3600, 3600, GY), IN("ornek", "Yumuşatma örneği", 4, 1, 32, "", GY),
    CL("camRenk", "Cam rengi", "#FFFFFF", GY), PC("renkGuc", "Cam renklendirme gücü", 0, g=GY),
    CS("isikTur", "Işık türü", ["Yok", "Noktasal", "Yönlü"], 0, GI), _u(XY("isikKonum", "Işık konumu", 75, 25, -100, 200, 0.1), "box%", GI, vis={"k": "isikTur", "in": [1, 2]}),
    PX("isikYuk", "Işık yüksekliği", 100, -1000, 2000, GI, {"k": "isikTur", "in": [1, 2]}), PC("isikGuc", "Işık gücü", 100, 0, 200, GI, {"k": "isikTur", "in": [1, 2]}),
    PC("ortam", "Ortam ışığı", 10, g=GI, vis={"k": "isikTur", "in": [1, 2]}), PC("yParlak", "Yüzey parlaklığı", 80, g=GI, vis={"k": "isikTur", "in": [1, 2]}),
    IN("keskin", "Yansıma keskinliği", 30, 1, 250, "", GI), CL("isikRenk", "Işık rengi", "#FFFFFF", GI, {"k": "isikTur", "in": [1, 2]})],
    [P("BC", "Buzlu cam", {"kirilma": 8, "puruz": 60, "isikTur": 2}), P("RC", "Renkli cam", {"renkGuc": 40, "isikTur": 1}, cols={"camRenk": "#6FC3FF"}),
     P("SC", "Sıvı cam", {"yukKayn": 1, "kirilma": 30, "isikTur": 1}), P("PZ", "Prizma", {"prizmaAyri": 14, "isikTur": 2}),
     P("SK", "Sabun köpüğü", {"prizmaAyri": 8, "renkGuc": 25, "isikTur": 1}, cols={"camRenk": "#FFD6F5"}), P("KR", "Kristal", {"pah": 40, "kirilma": 25, "isikTur": 1, "keskin": 120})], True)

# 189 Gürültü
OPTS("noise", "tur", ["Yumuşak", "Blok"])
G189 = "Gelişmiş Gürültü"
ADD("noise", [TG("dondur", "Deseni dondur", 0, G189), IN("yenilenme", "Yenilenme aralığı", 1, 1, 120, " kare", G189), XYP("grenOran", "Gren oranı", 100, 100, 1, 1000, "%", G189, link=True),
    PC("golgeYog", "Gölgelerdeki yoğunluk", 100, 0, 200, G189), PC("ortaYog", "Orta tonlardaki yoğunluk", 100, 0, 200, G189), PC("acikYog", "Açık tonlardaki yoğunluk", 100, 0, 200, G189)])
for p in _BY["noise"]["params"]:
    if p["k"] == "zamanaBagl": p["hideUi"] = True  # "Deseni dondur" bunun tersidir; ikisi aynı anda gösterilmez

# 191 Blok Gürültü
G191 = "Gelişmiş"
ADD("blocknoise", [XYP("esnet", "Blok esnetme", 100, 100, 1, 1000, "%", G191, link=True), PC("guc", "Efekt gücü", 100, g=G191), XYP("kaydir", "Desen kaydırma", 0, 0, -4000, 4000, "px", G191),
    TG("dondur", "Deseni dondur", 0, G191), TG("ucDeger", "Yalnız uç değerler", 0, G191), PC("parlakUst", "Parlaklık üst sınırı", 100, 50, 200, G191),
    CS("karistir", "Karıştırma", ["Normal", "Çarp", "Ekran", "Ekle"], 0, G191), TG("tohumAK", "Tohumu anahtar kareyle değiştir", 0, G191)])

# 218 Hücre Deseni
G218 = "Hücre Biçimi"
ADD("cellpattern", [PC("duzensiz", "Hücre düzensizliği", 100, g=G218), PC("esneklik", "Hücre esnekliği", 0, g=G218), XYP("oran", "Hücre oranı", 100, 100, 1, 1000, "%", G218, link=True),
    PX("bosluk", "Hücre arası boşluk", 0, 0, 100, G218), PC("kabartma", "Hücre içi kabartma", 0, g=G218),
    CS("renklendir", "Hücre renklendirme", ["Sabit", "Rastgele", "Kaynak görsel", "Renk geçişi"], 0, G218), TG("merkezGoster", "Hücre merkezlerini göster", 0, G218)],
    [P("KR", "Kristal", {"desen": 2, "kabartma": 40, "renklendir": 1}), P("TS", "Taş", {"desen": 3, "duzensiz": 90, "kabartma": 60, "bosluk": 2}), P("BH", "Biyolojik hücre", {"desen": 1, "esneklik": 60, "renklendir": 3}),
     P("CY", "Çatlak yüzey", {"desen": 0, "kenarKali": 2, "duzensiz": 100}), P("BP", "Bal peteği", {"duzensiz": 0, "bosluk": 3, "kabartma": 30}, cols={"renk1": "#C88A12", "renk2": "#FFC940"}),
     P("VR", "Voronoi", {"renklendir": 1})], True)

# 286 Kroma Anahtarı
G286 = "Gelişmiş Anahtar"
ADD("chromakey", [CS("yontem", "Renk karşılaştırma yöntemi", ["Renk farkı", "RGB", "HSV"], 0, G286), PC("siyahAlfa", "Siyah alfa noktası", 0, g=G286), PC("beyazAlfa", "Beyaz alfa noktası", 100, g=G286),
    PC("yariSaydam", "Yarı saydamlık koruması", 50, g=G286), PC("kenarTemiz", "Kenar temizleme", 0, g=G286), TG("ayrintiKoru", "İnce ayrıntıları koru", 1, G286),
    TG("cokluAnahtar", "Birden fazla anahtar rengi", 0, G286), CL("anahtar2", "İkinci anahtar rengi", "#0047FF", G286, {"k": "cokluAnahtar", "in": [1]}),
    CL("anahtar3", "Üçüncü anahtar rengi", "#00FF00", G286, {"k": "cokluAnahtar", "in": [1]}), TG("anahtar3Acik", "Üçüncü anahtar rengini kullan", 0, G286, {"k": "cokluAnahtar", "in": [1]}),
    CS("onizleme", "Önizleme", ["Sonuç", "Alfa", "Siyah arka plan", "Beyaz arka plan"], 0, G286)])

# 288 Düz Mat
G288 = "Arka Plan Doldurma"; vb = {"k": "dolguMod", "in": [2, 3]}
ADD("solidmatte", [CS("dolguMod", "Dolgu modu", ["Düz renk", "Renk geçişi", "Bulanık kaynak kopyası", "Özel görsel"], 0, G288), CL("renk2", "Geçiş ikinci rengi", "#1B2A55", G288, {"k": "dolguMod", "in": [1]}),
    LAY("ozelGorsel", "Özel arka plan görseli", G288, {"k": "dolguMod", "in": [3]}), PX("bgBulanik", "Arka plan bulanıklığı", 30, 0, 500, G288, vb), PC("bgDoyg", "Arka plan doygunluğu", 0, -100, 100, G288, vb),
    PC("bgParlak", "Arka plan parlaklığı", 0, -100, 100, G288, vb), _u(J("bgGama", "Arka plan gama", 0.01, 10, 1, 0.01, 0.01), "", G288, vis=vb), PC("bgRenklendir", "Arka plan renklendirme", 0, g=G288, vis=vb),
    CL("renklendirRenk", "Renklendirme rengi", "#FFFFFF", G288, vb), PX("onYumu", "Ön plan kenar yumuşaklığı", 0, 0, 100, G288, vb), PC("onOpak", "Ön plan opaklığı", 100, g=G288, vis=vb),
    XYP("onKay", "Ön plan kayması", 0, 0, -4000, 4000, "px", G288, vb), XYP("bgKay", "Arka plan kayması", 0, 0, -4000, 4000, "px", G288, vb),
    PC("onOlcek", "Ön plan ölçeği", 100, 1, 1000, G288, vb), PC("bgOlcek", "Arka plan ölçeği", 100, 1, 1000, G288, vb), PC("taramaGuc", "Arka plan tarama çizgisi gücü", 0, g=G288, vis=vb),
    IN("taramaSayi", "Tarama çizgisi sayısı", 720, 100, 2160, "", G288, vb)])

# 334 Fraktal Gürültü
G334 = "Gelişmiş"
ADD("fractalnoise", [XYP("olcekXY", "Gürültü ölçeği", 100, 100, 1, 1000, "%", G334, link=True), TG("orantili", "Orantılı ölçek", 1, G334), PC("altOlcek", "Alt katman ölçeği", 50, 1, 100, G334),
    PC("altEtki", "Alt katman etkisi", 50, g=G334), DG("altDonus", "Alt katman dönüşü", 0, -3600, 3600, G334), XYP("altKayma", "Alt katman kayması", 0, 0, -4000, 4000, "px", G334),
    _u(J("evrimHiz", "Evrim hızı", -3600, 3600, 0, 0.1, 0.1), "°/sn", G334), TG("dongu", "Kusursuz döngü", 0, G334), _u(J("donguSure", "Döngü süresi", 0.1, 60, 3, 0.01, 0.01), "s", G334, vis={"k": "dongu", "in": [1]}),
    CS("gorunum", "Gürültü görünümü", ["Yumuşak", "Keskin", "Blok", "Sırtlı", "Hücresel"], 0, G334), CL("koyuRenk", "Koyu bölge rengi", "#000000", G334), CL("acikRenk", "Açık bölge rengi", "#FFFFFF", G334)])

# 367 Doğrusal Silme
G367 = "Silme Modu ve Kenar"
ADD("linwipe", [CS("mod", "Silme modu", ["Tek taraftan", "Çift taraftan", "Merkezden"], 0, G367), PC("basSinir", "Başlangıç sınırı", 0, g=G367), PC("bitSinir", "Bitiş sınırı", 100, g=G367),
    TG("sinirBagla", "Başlangıç ve bitişi bağla", 0, G367), TG("kenarCizgi", "Kenar çizgisi", 0, G367), CL("kenarRenk", "Kenar çizgisi rengi", "#FFFFFF", G367, {"k": "kenarCizgi", "in": [1]}),
    PX("kenarKalin", "Kenar çizgisi kalınlığı", 2, 0, 100, G367, {"k": "kenarCizgi", "in": [1]}), TG("kenarParla", "Kenar parlaması", 0, G367),
    PX("parlaBuyu", "Parlama büyüklüğü", 10, 0, 300, G367, {"k": "kenarParla", "in": [1]})])

# 225–248 Ortak 3B sistemi: dönüşüm, kamera, malzeme, ışık ve gölge (her 3B nesneye)
GD, GK, GM, GL = "3B Dönüşüm", "Kamera", "Malzeme", "Işık ve Gölge"
COMMON3D = [
    _u(dict(k="olcekXYZ", l="Ölçek", kind="jog", three=True, min=1, max=1000, def_=100, defY=100, defZ=100, step=0.1, jog=0.1), "%", GD, link=True), TG("orantili", "Orantılı ölçek", 1, GD),
    _u(dict(k="donusMerk", l="Dönüş merkezi", kind="jog", three=True, min=-5000, max=5000, def_=0, defY=0, defZ=0, step=0.1, jog=0.1), "px", GD),
    CS("donusYontem", "Dönüş yöntemi", ["Eksen bazlı", "En kısa yönelim"], 0, GD), TG("otoDonus", "Otomatik dönüş", 0, GD),
    PX("kameraUzak", "Kamera uzaklığı", 800, 10, 10000, GK), PC("perspGuc", "Perspektif gücü", 100, g=GK),
    CS("malzeme", "Malzeme", ["Mat", "Metal", "Plastik", "Cam", "Kâğıt", "Karton", "Ahşap", "Özel"], 0, GM), CL("tabanRenk", "Taban rengi", "#FFFFFF", GM),
    SRC("ozelDoku3", "Özel doku", GM, {"k": "malzeme", "in": [7]}), PC("dokuGucu3", "Doku gücü", 100, g=GM), XYP("dokuOlcek3", "Doku ölçeği", 100, 100, 1, 1000, "%", GM, link=True),
    XYP("dokuKonum3", "Doku konumu", 0, 0, -4000, 4000, "px", GM), DG("dokuAci3", "Doku açısı", 0, -360, 360, GM), PC("metalik", "Metalik görünüm", 0, g=GM),
    PC("kabartma3", "Kabartma", 0, g=GM), PC("opaklik3", "Opaklık", 100, g=GM),
    CS("golgelendirme", "Gölgelendirme", ["Düz", "Noktasal", "Yönlü"], 1, GL), TG("golgeOlustur", "Gölge oluştur", 1, GL), PC("golgeOpak3", "Gölge opaklığı", 35, g=GL, vis={"k": "golgeOlustur", "in": [1]}),
    PX("golgeYumu3", "Gölge yumuşaklığı", 12, 0, 100, GL, {"k": "golgeOlustur", "in": [1]}), CS("kalite3", "Geometri kalitesi", ["Otomatik", "Düşük", "Orta", "Yüksek", "Ultra"], 0, GL)]
for _e in E:
    if _e["kind"] == "3d" and any(p["k"] == "yonelimXY" for p in _e["params"]):
        for p in _e["params"]:
            if p["k"] == "konumXY": p["min"], p["max"] = -5000, 5000; p["g"] = GD; p["l"] = "Konum"
            if p["k"] == "yonelimXY": p["min"], p["max"] = -3600, 3600; p["g"] = GD; p["l"] = "Dönüş"
            if p["k"] == "surekliDonuX": p["g"] = GD; p["l"] = "Dönüş hızı (°/sn)"
            if p["k"] in ("perspekt", "gorusAcis"): p["g"] = GK
            if p["k"] == "perspekt": p["l"] = "Kamera"; p["opts"] = ["Perspektif", "Ortografik", "Proje kamerası"]; p["max"] = 2
            if p["k"] in ("isikEtki", "isikKonu", "isikReng", "ortamIsig", "yonluIsikGucu", "parlakYans", "puruzlul", "arkaYuzlGost", "kenarYumu"): p["g"] = GL
            if p["k"] == "yonluIsikGucu": p["l"] = "Işık gücü"
            if p["k"] == "parlakYans": p["l"] = "Parlaklık"; p["g"] = GM
            if p["k"] == "puruzlul": p["l"] = "Pürüzlülük"; p["g"] = GM
        ADD(_e["type"], [dict(p) for p in COMMON3D])

# 237 Kalınlık Ver
G237 = "Kalınlık"
ADD("extrude", [CS("kalinYon", "Kalınlaştırma yönü", ["İki tarafa", "Öne", "Arkaya"], 0, G237), PC("yanRenkGuc", "Yan yüz renklendirme gücü", 100, g=G237), TG("derinGecis", "Derinliğe bağlı renk geçişi", 0, G237),
    CL("derinSonRenk", "Derinlik sonu rengi", "#000000", G237, {"k": "derinGecis", "in": [1]}), PC("gecisGuc", "Renk geçişi gücü", 100, g=G237, vis={"k": "derinGecis", "in": [1]}),
    IN("pahSegment", "Pah segmenti", 4, 1, 32, "", G237), TG("inceKoru", "İnce ayrıntıları koru", 1, G237), PX("siluetYumu", "Siluet yumuşatma", 1, 0, 30, G237),
    CS("alfaYorum", "Alfa yorumu", ["Sert", "Yumuşak", "Ağırlıklı", "Eşiğe göre"], 2, G237), PC("alfaEsik", "Alfa eşiği", 35, g=G237, vis={"k": "alfaYorum", "in": [3]}), TG("sekilGuncel", "Şekil değişiminde geometriyi güncelle", 1, G237)])

# 401 Bayrak Dalgalanması
GF = "Kumaş ve Rüzgâr"
ADD("flagwave", [PC("sertlik", "Kumaş sertliği", 50, g=GF), PC("agirlik", "Kumaş ağırlığı", 20, g=GF), PX("sarkma", "Sarkma miktarı", 0, 0, 500, GF), TG("degisken", "Değişken rüzgâr", 0, GF),
    PC("degisGuc", "Rüzgâr değişim gücü", 20, g=GF, vis={"k": "degisken", "in": [1]}), _u(J("degisSik", "Rüzgâr değişim sıklığı", 0, 10, 0.5, 0.01, 0.01), "Hz", GF, vis={"k": "degisken", "in": [1]}),
    PC("ucTitre", "Uç bölgesi titreşimi", 15, g=GF), PC("kumasParlak", "Kumaş parlaklığı", 10, g=GF), PC("kumasDoku", "Kumaş doku gücü", 0, g=GF),
    TG("arkaGoster", "Arka yüzü göster", 1, GF), CS("arkaYuz", "Arka yüz", ["Aynalanmış ön yüz", "Özel görsel", "Düz renk"], 0, GF, {"k": "arkaGoster", "in": [1]}),
    LAY("arkaGorsel", "Özel arka yüz görseli", GF, {"k": "arkaYuz", "in": [1]}), CL("arkaRenk", "Arka yüz rengi", "#DDDDDD", GF, {"k": "arkaYuz", "in": [2]})],
    [P("HR", "Hafif rüzgâr", {"dalgaYuks": 8, "dalgaBoyu": 150, "ruzgarHizi": 0.5}), P("GR", "Güçlü rüzgâr", {"dalgaYuks": 40, "dalgaBoyu": 75, "ruzgarHizi": 2, "ucTitre": 40}),
     P("AK", "Ağır kumaş", {"dalgaYuks": 15, "agirlik": 70, "sarkma": 25, "ruzgarHizi": 0.7}), P("IK", "İnce kumaş", {"dalgaYuks": 25, "sertlik": 15, "ucTitre": 50, "ruzgarHizi": 1.8}),
     P("CF", "Çizgi film", {"dalgaYuks": 20, "ikinciDalg": 0, "duzensiz": 0, "kumasParlak": 30}), P("KB", "Kâğıt bayrak", {"dalgaYuks": 10, "sertlik": 85, "kumasDoku": 40})])
# 402 CB Yuvarlak Gölgelendirme
GS = "Parlaklık ve İkinci Işık"
ADD("cbshade", [PC("yuzeyParlak", "Yüzey parlaklığı", 0, g=GS), PC("noktaBuyu", "Parlak nokta büyüklüğü", 20, g=GS), PC("noktaGuc", "Parlak nokta gücü", 0, g=GS), TG("isik2", "İkinci ışık kaynağı", 0, GS),
    _u(XY("isik2Konum", "İkinci ışık konumu", 75, 30, -100, 200, 0.1), "box%", GS, vis={"k": "isik2", "in": [1]}), CL("isik2Renk", "İkinci ışık rengi", "#53A8FF", GS, {"k": "isik2", "in": [1]}),
    PC("isik2Guc", "İkinci ışık gücü", 20, g=GS, vis={"k": "isik2", "in": [1]}), TG("bayrakKoru", "Bayrak renklerini koru", 1, GS), TG("konturIsik", "Siyah konturu ışıklandır", 0, GS)],
    [P("DC", "Düz çizgi film", {"isikGucu": 15, "golgeGucu": 20, "yumusakl": 20}), P("GK", "Gerçekçi küre", {"isikGucu": 35, "golgeGucu": 50, "noktaGuc": 60, "yuzeyParlak": 30}),
     P("KR", "Karton", {"isikGucu": 15, "golgeGucu": 25, "kenarKara": 25, "yuzeyParlak": 0}), P("PO", "Plastik oyuncak", {"noktaGuc": 90, "noktaBuyu": 12, "yuzeyParlak": 60}),
     P("YG", "Yumuşak gölge", {"golgeGucu": 30, "yumusakl": 95, "isikGucu": 10})])
# 413 CB Bayrak Kaplama
GB = "Yüzey Eşleme"
ADD("cbskin", [CS("esleme", "Yüzey eşleme", ["Düz", "Küresel", "Eliptik"], 1, GB), DG("kureDonus", "Küresel dönüş", 0, -360, 360, GB), DG("dikeyDonus", "Dikey yüzey dönüşü", 0, -90, 90, GB),
    TG("yuzeySabit", "Bayrağı yüzeyde sabitle", 1, GB), TG("sekilTakip", "Karakter şekil değişimini takip et", 1, GB), PC("yuzeyKabar", "Yüzey kabartması", 0, g=GB), TG("aksesuarKoru", "Gözlerin ve aksesuarların rengini koru", 1, GB)])
# 416 CB Harita Vurgusu
GH = "Dolgu ve Çizim"
ADD("cbmaphl", [CS("dolguBicim", "Dolgu biçimi", ["Düz renk", "Geçiş", "Bayrak", "Tarama", "Nokta", "Doku"], 0, GH), CL("dolgu2", "Geçiş ikinci rengi", "#22D3C5", GH, {"k": "dolguBicim", "in": [1]}),
    LAY("dolguGorsel", "Bayrak veya doku görseli", GH, {"k": "dolguBicim", "in": [2, 5]}), DG("taramaAci", "Tarama açısı", 45, -360, 360, GH, {"k": "dolguBicim", "in": [3]}),
    PX("taramaAral", "Tarama aralığı", 8, 1, 200, GH, {"k": "dolguBicim", "in": [3, 4]}), PX("taramaKalin", "Tarama kalınlığı", 3, 0, 100, GH, {"k": "dolguBicim", "in": [3, 4]}),
    TG("sinirKirp", "Bölge sınırına kırp", 1, GH), TG("sinirCiz", "Sınırı çizerek göster", 0, GH), PC("cizimIler", "Sınır çizim ilerlemesi", 100, g=GH, vis={"k": "sinirCiz", "in": [1]}),
    PC("dolguIler", "Dolgu belirme ilerlemesi", 100, g=GH), TG("konturSabit", "Kontur kalınlığını kamera yakınlaşmasından bağımsız tut", 1, GH)])
# 428 CB Çıkartma Konturu (eski kimlik "cbsticker" korunur)
_BY["cbsticker"]["name"] = "CB Çıkartma Konturu"
GC = "Altlık ve Malzeme"
ADD("cbsticker", [CS("altlikBicim", "Altlık biçimi", ["Düz kontur", "Çift kontur", "Kesilmiş altlık"], 1, GC), CS("alfaYorum", "Alfa yorumu", ["Sert", "Yumuşak", "Ağırlıklı", "Eşiğe göre"], 2, GC),
    PC("alfaEsik", "Alfa eşiği", 35, g=GC, vis={"k": "alfaYorum", "in": [3]}), XYP("disKayma", "Dış kontur kayması", 0, 0, -1000, 1000, "px", GC), TG("malzDoku", "Malzeme dokusu", 0, GC),
    CS("malz", "Malzeme", ["Kâğıt", "Karton", "Mukavva", "Plastik", "Özel"], 0, GC, {"k": "malzDoku", "in": [1]}), LAY("malzOzel", "Özel malzeme", GC, {"k": "malz", "in": [4]}),
    PC("dokuGucuS", "Doku gücü", 30, g=GC, vis={"k": "malzDoku", "in": [1]})])
