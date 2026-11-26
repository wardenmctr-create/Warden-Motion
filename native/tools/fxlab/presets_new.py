# Yeni efektlerin hazır şablonları (rehberdeki şablon adları; değerler denenerek seçildi)
def NPS(t, *ps):
    if t in _BY: _BY[t]["presets"] = list(ps)
NPS("globe3d", P("SD", "Siyasi Dünya", {"harita": 0, "ulkeSini": 1, "bulutlar": 0}), P("GD", "Gerçekçi Dünya", {"harita": 2, "bulutlar": 1, "atmosfer": 1}),
    P("GC", "Gece", {"harita": 3, "geceIsik": 1, "bulutlar": 0}), P("CF", "Çizgi film", {"harita": 0, "ulkeSini": 1, "sinirKali": 3, "bulutlar": 0, "atmosferKali": 8}),
    P("KD", "Karton Dünya", {"harita": 1, "malzeme": 5, "bulutlar": 0, "atmosfer": 0}))
NPS("planet3d", P("MR", "Mars", {"gezegenTuru": 3, "kraterYogu": 30}, cols={"anaRenk": "#C1440E", "ikinciRenk": "#7A2A10", "atmosferReng": "#E8A07A"}),
    P("JP", "Jüpiter", {"gezegenTuru": 1, "bulutSeriSayi": 14, "firtinaYogu": 50}, cols={"anaRenk": "#D8B48A", "ikinciRenk": "#9C6B4A"}),
    P("NP", "Neptün", {"gezegenTuru": 1, "bulutSeriSayi": 6, "firtinaYogu": 20}, cols={"anaRenk": "#3B6BE0", "ikinciRenk": "#1B2F8A", "atmosferReng": "#8FC8FF"}),
    P("LV", "Lav gezegeni", {"gezegenTuru": 4}, cols={"anaRenk": "#2A1A14", "ikinciRenk": "#FF5A1F"}), P("HY", "Hayalî gezegen", {"gezegenTuru": 5, "tohum": 7}, cols={"anaRenk": "#22C3B5", "ikinciRenk": "#8E44D9"}))
NPS("ringplanet", P("ST", "Satürn", {}), P("BH", "Buz halkası", {"parcacikYogu": 85}, cols={"anaRenk": "#DDEBFF", "ikinciRenk": "#8FC8FF"}),
    P("TH", "Toz halkası", {"parcacikYogu": 45, "halkaOpak": 55}, cols={"anaRenk": "#B89B7A", "ikinciRenk": "#6B5544"}),
    P("NH", "Neon halka", {"halkaSayi": 3, "halkaBosl": 30}, cols={"anaRenk": "#22D3E6", "ikinciRenk": "#FF6FAE"}))
NPS("flagpole3d", P("MB", "Masa bayrağı", {"direkYuks": 260, "direkKali": 5, "dalgaYuks": 6, "direkTepe": 0}), P("TB", "Tören bayrağı", {"direkYuks": 800, "dalgaYuks": 26, "ruzgarHizi": 0.8}),
    P("CF", "Çizgi film", {"dalgaYuks": 30, "dalgaBoyu": 160, "direkMalz": 2}, cols={"direkReng": "#FFD43B"}), P("GR", "Güçlü rüzgâr", {"dalgaYuks": 45, "dalgaBoyu": 80, "ruzgarHizi": 2.5}))
NPS("book3d", P("TK", "Tarih kitabı", {"acilmaAcis": 120}, cols={"sayfaReng": "#F3E9D2"}), P("AT", "Atlas", {"acilmaAcis": 160, "kalinlik": 25}),
    P("DF", "Defter", {"sayfaCizg": 1, "acilmaAcis": 150, "kapakKali": 2}, cols={"sayfaReng": "#FFFFFF"}), P("EK", "Eski kitap", {"acilmaAcis": 110, "sayfaKivr": 60}, cols={"sayfaReng": "#E0C99A"}),
    P("CR", "Çizgi roman", {"acilmaAcis": 170, "kalinlik": 12}))
NPS("dice3d", P("KZ", "Klasik zar", {}), P("AZ", "Ahşap", {"malzeme": 6}, cols={"zarReng": "#C9A27A", "isaretReng": "#3A2414"}),
    P("MZ", "Metal", {"malzeme": 1}, cols={"zarReng": "#C0C0C8"}), P("YV", "Yuvarlanan zar", keys={"yuvarlanIler": [[0, 0], [1.5, 100]]}, vals={"otomatikYuva": 1}))
NPS("gear3d", P("SD", "Saat dişlisi", {"disSayi": 40, "disYuks": 8, "kalinlik": 8, "destekKoll": 1}, cols={}), P("MD", "Mekanik dişli", {"disSayi": 16, "kalinlik": 30, "malzeme": 1}),
    P("CF", "Çizgi film", {"disSayi": 10, "disYuks": 25, "destekKoll": 1, "destekKoluSayi": 4}))
NPS("chain3d", P("MZ", "Metal zincir", {"malzeme": 1}), P("DZ", "Dekoratif zincir", {"halkaBici": 1, "yol": 1}), P("AZ", "Altın zincir", {"malzeme": 1, "yol": 3}, cols={"tabanRenk": "#D4AF37"}))
NPS("coin3d", P("AL", "Altın", {"malzeme": 1}, cols={"tabanRenk": "#D4AF37"}), P("GM", "Gümüş", {"malzeme": 1}, cols={"tabanRenk": "#C0C0C8"}),
    P("BR", "Bronz", {"malzeme": 1}, cols={"tabanRenk": "#A97142"}), P("OP", "Oyun parası", {"otomatikDonm": 1, "donmeHizi": 180, "malzeme": 1}, cols={"tabanRenk": "#FFD43B"}),
    P("UR", "Ülke rozeti", {"bicim": 1, "kenarSayi": 8, "tirtikliKena": 0}))
NPS("pipe3d", P("CB", "Cam boru", {"malzeme": 3}), P("MB", "Metal boru", {"malzeme": 1}), P("NB", "Neon boru", {"boruYolu": 2}, cols={"tabanRenk": "#22D3E6"}),
    P("KR", "Karton rulo", {"malzeme": 5, "duvarKali": 3}))
NPS("meteors", P("YK", "Yıldız kayması", {"meteorYogu": 4, "buyukluk": 3}), P("RM", "Renkli meteor", {"meteorYogu": 20}, cols={"kuyrukReng": "#FF6FAE"}),
    P("CG", "Çizgi film gökyüzü", {"meteorYogu": 10, "buyukluk": 8, "izUzun": 90}, cols={"meteorReng": "#FFD43B", "kuyrukReng": "#FF8F1F"}))
NPS("blackhole", P("SK", "Sinematik kara delik", {}), P("KP", "Kozmik portal", {"diskEgim": 0, "girdapEtki": 70}, cols={"icDiskReng": "#E6F1FF", "disDiskReng": "#8E44D9"}),
    P("MG", "Mavi girdap", {"girdapEtki": 60, "diskEgim": 40}, cols={"icDiskReng": "#FFFFFF", "disDiskReng": "#2F7BFF"}))
NPS("nebula", P("MB", "Mavi bulutsu", {}, cols={"birinciRenk": "#1B2A55", "ikinciRenk": "#2F7BFF", "ucuncuRenk": "#22D3E6"}),
    P("KB", "Kırmızı bulutsu", {}, cols={"birinciRenk": "#7B1E2B", "ikinciRenk": "#E53935", "ucuncuRenk": "#FF8F1F"}), P("MU", "Mor uzay", {}),
    P("KU", "Karanlık uzay", {"gazYogu": 30, "yildizYogu": 60}, cols={"birinciRenk": "#0B0F1E", "ikinciRenk": "#1B2A55", "ucuncuRenk": "#44474D"}))
NPS("sunsurface", P("SY", "Sarı yıldız", {}), P("MY", "Mavi yıldız", {}, cols={"anaRenk": "#5AA0FF", "sicakBolg": "#E6F1FF", "koyuBolg": "#1B4FD9"}),
    P("KD", "Kırmızı dev", {"buyukluk": 400}, cols={"anaRenk": "#E53935", "sicakBolg": "#FF8F1F", "koyuBolg": "#7B1E2B"}), P("SG", "Stilize Güneş", {"yuzeyAyri": 30, "plazmaYayl": 0, "lekeYogu": 0}))
NPS("tornado", P("UG", "Uydu görünümü", {"gorunum": 0}), P("CF", "Çizgi film", {"gorunum": 1, "turbulan": 20}), P("TG", "Toz girdabı", {"gorunum": 2}, cols={"bulutReng": "#C9A27A"}))
NPS("sandstorm", P("HT", "Hafif toz", {"yogunluk": 35, "gorusAzal": 10}), P("CL", "Çöl", {}), P("CK", "Çizgi film kumu", {"kumBuyu": 4, "turbulan": 20}, cols={"kumReng": "#D8B97A"}))
NPS("leaffall", P("SB", "Sonbahar", {"yaprakTuru": 0}), P("IB", "İlkbahar", {"yaprakTuru": 1}, cols={"yaprakRenk": "#9BE27A"}),
    P("KC", "Kiraz çiçeği", {"yaprakTuru": 3, "buyukluk": 14}, cols={"yaprakRenk": "#FFC0D9"}), P("YY", "Yeşil yapraklar", {"yaprakTuru": 1}, cols={"yaprakRenk": "#3BB54A"}))
NPS("droplets", P("YP", "Yağmurlu pencere", {"damlaSayi": 70, "damlaHare": 1}), P("CY", "Çiy", {"damlaSayi": 120, "damlaBuyu": 6, "damlaHare": 0}),
    P("KD", "Kamera damlası", {"damlaSayi": 8, "damlaBuyu": 60, "damlaHare": 0, "isikKiri": 70}))
NPS("frostglass", P("HK", "Hafif kırağı", {"donmaMikt": 35}), P("DP", "Donmuş pencere", {"donmaMikt": 80, "bulanikl": 25}), P("BK", "Buz kristalleri", {"kristalBuyu": 60, "dallanma": 85}))
NPS("wetsurface", P("IA", "Islak asfalt", {"yuzeyKara": 30, "puruzlul": 40}), P("TS", "Taş", {"islaklik": 50}), P("MT", "Metal", {"yansimaGucu": 70, "puruzlul": 10}),
    P("PS", "Parlak su", {"suBiri": 1, "birikintYogu": 45, "yansimaGucu": 75}))
NPS("perspgrid", P("RN", "Retro neon zemin", {"parlama": 1, "hareketHizi": 120}, cols={"cizgiReng": "#FF6FAE"}), P("TC", "Teknik çizim", {"parlama": 0}, cols={"cizgiReng": "#1B2A55"}),
    P("DO", "Dijital ortam", {"hareketHizi": 60}, cols={"cizgiReng": "#22D3E6"}))
NPS("infmirror", P("ST", "Sonsuz tünel", {}), P("NP", "Neon portal", {"renkGeci": 1}, cols={"uzakKopyReng": "#FF6FAE"}), P("DA", "Dönen ayna", {"kopyaDonu": 15}))
NPS("depthparallax", P("FC", "Fotoğraf canlandırma", {"derinlikKayn": 3}, keys={"kameraKaym": [[0, -20], [3, 20]]}), P("MN", "Manzara", {"derinlikKayn": 3, "paralaksGucu": 70}, keys={"yakinlas": [[0, 100], [3, 115]]}),
    P("CS", "Countryballs sahne derinliği", {"derinlikKayn": 3, "paralaksGucu": 40}, keys={"kameraKaym": [[0, 0], [2, 25]]}))
NPS("ambientocc", P("KD", "Karton derinliği", {"golgeYari": 15, "yogunluk": 35}), P("TG", "Temas gölgesi", {"golgeYari": 8, "yogunluk": 60}),
    P("OY", "Oyuncak", {"golgeYari": 25, "yumusakl": 20}), P("G3", "Güçlü 3B gölge", {"golgeYari": 40, "yogunluk": 75}))
NPS("volumelight", P("PI", "Pencere ışığı", {"isikTuru": 1, "sisYogu": 30}), P("SI", "Sahne ışığı", {"isikTuru": 0}), P("SS", "Sinematik sis", {"sisYogu": 70, "havadakiTozl": 1}))
NPS("inkdraw", P("ME", "Mürekkep eskizi", {}), P("CR", "Çizgi roman", {"cizgiKali": 3, "orijinalRenkKoru": 80, "taramaYogu": 10}), P("GR", "Gravür", {"taramaYogu": 85, "cizgiKali": 1}))
NPS("embroidery", P("NB", "Nakışlı bayrak", {"dikisTuru": 3}), P("AR", "Arma", {"dikisTuru": 3, "kenarDiki": 1, "renkSayi": 8}), P("KK", "Keçe karakter", {"kumasAltl": 1, "dikisTuru": 0}),
    P("IR", "İşlenmiş rozet", {"dikisTuru": 4, "kumasAltl": 1}))
NPS("pencilhatch", P("TC", "Teknik çizim", {"tarama": 0, "cizgiAral": 4}), P("KE", "Klasik eskiz", {"tarama": 1}), P("YT", "Yoğun tarama", {"tarama": 2, "taramaKatm": 5, "cizgiAral": 3}))
NPS("photocopy", P("TF", "Temiz fotokopi", {"gurultu": 10, "lekeYogu": 0, "baskiCizg": 0}), P("EB", "Eski belge", {"kopyaNesl": 4}), P("BY", "Bozuk yazıcı", {"baskiCizg": 1, "tonerTasm": 3, "gurultu": 50}),
    P("YK", "Yirminci kopya", {"kopyaNesl": 20}))
NPS("datacorrupt", P("DE", "Dijital erime", {"hareketYayi": 90, "bozulmaMikt": 60}), P("DG", "Donmuş görüntü", {"blokYogu": 60, "blokKaym": 5}),
    P("SH", "Sıkıştırma hatası", {"blokBuyu": 8, "renkBozu": 50}), P("HB", "Hareketli bloklar", {"blokKaym": 70, "yenilenmAral": 2}))
# Varsayılan boyutlar katman kutusuna sığacak şekilde (rehberdeki aralıklar korunur)
def DEF(t, k, v, vy=None):
    for p in _BY[t]["params"]:
        if p["k"] == k:
            p["def_"] = v
            if vy is not None: p["defY"] = vy
DEF("globe3d", "buyukluk", 220); DEF("book3d", "kitapBoyu", 150, 210); DEF("dice3d", "yuzSayi", 1); DEF("flagpole3d", "bayrakBoyu", 150, 100); DEF("flagpole3d", "direkYuks", 320)
DEF("pipe3d", "uzunluk", 260); DEF("chain3d", "baslangiNokt", 15, 50); DEF("chain3d", "bitisNokt", 85, 50); DEF("planet3d", "buyukluk", 220); DEF("sunsurface", "buyukluk", 200)
