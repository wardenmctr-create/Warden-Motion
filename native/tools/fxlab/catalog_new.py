# Yeni efektler: Bölüm C (433–462) ve 550 rehberi (463–550). spec2.json'dan ayarlar okunur; shader'ı hazır olmayanlar gizli kalır.
_SP2 = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "spec2.json"), encoding="utf-8"))
_C = {c: i for i, c in enumerate(CATS)}
NEW = {  # n: (tür, kategori, tür(kind), etiketler, ped)
 433: ("globe3d", "3B", "3d", ["Dünya", "Harita", "Gezegen"], {"box": 0.45}), 434: ("planet3d", "3B", "3d", ["Gezegen", "Uzay"], {"box": 0.45}),
 435: ("ringplanet", "3B", "3d", ["Gezegen", "Halka", "Uzay"], {"box": 0.8}), 436: ("flagpole3d", "3B", "3d", ["Bayrak", "Direk", "Rüzgâr"], {"box": 0.6}),
 437: ("book3d", "3B", "3d", ["Kitap", "Sayfa"], {"box": 0.6}), 438: ("dice3d", "3B", "3d", ["Zar", "Oyun"], {"box": 0.45}),
 439: ("gear3d", "3B", "3d", ["Dişli", "Mekanik"], {"box": 0.45}), 440: ("chain3d", "3B", "3d", ["Zincir", "Metal"], {"box": 0.6}),
 441: ("coin3d", "3B", "3d", ["Para", "Rozet"], {"box": 0.45}), 442: ("pipe3d", "3B", "3d", ["Boru", "Tüp"], {"box": 0.6}),
 443: ("meteors", "Simülasyon", "gen", ["Uzay", "Gökyüzü", "Parçacık"], None), 444: ("blackhole", "Simülasyon", "pixel", ["Uzay", "Bükme", "Mercek"], {"box": 0.3}),
 445: ("nebula", "Prosedürel", "gen", ["Uzay", "Bulut", "Renk"], None), 446: ("sunsurface", "Prosedürel", "gen", ["Güneş", "Yıldız", "Uzay"], {"box": 0.4}),
 447: ("tornado", "Simülasyon", "gen", ["Fırtına", "Girdap", "Hava"], None), 448: ("sandstorm", "Simülasyon", "pixel", ["Kum", "Toz", "Rüzgâr"], None),
 449: ("leaffall", "Simülasyon", "gen", ["Yaprak", "Mevsim", "Parçacık"], None), 450: ("droplets", "Simülasyon", "pixel", ["Su", "Damla", "Cam"], None),
 451: ("frostglass", "Simülasyon", "pixel", ["Buz", "Kırağı", "Cam"], None), 452: ("wetsurface", "Renk ve Işık", "pixel", ["Su", "Yansıma", "Islak"], None),
 453: ("perspgrid", "Prosedürel", "gen", ["Izgara", "Retro", "Zemin"], None), 454: ("infmirror", "Tekrar", "repeat", ["Ayna", "Tünel", "Sonsuz"], None),
 455: ("depthparallax", "Bükme ve Bozulma", "pixel", ["Derinlik", "Paralaks", "Kamera"], {"k": "kameraKaym", "mul": 0.5, "add": 10}),
 456: ("ambientocc", "Renk ve Işık", "pixel", ["Gölge", "Derinlik", "Hacim"], {"k": "golgeYari", "mul": 1.0}),
 457: ("volumelight", "Renk ve Işık", "pixel", ["Işık", "Sis", "Huzme"], None), 458: ("inkdraw", "Çizim ve Kenar", "pixel", ["Mürekkep", "Çizim", "Eskiz"], None),
 459: ("embroidery", "Çizim ve Kenar", "pixel", ["Nakış", "İplik", "Kumaş"], {"add": 6}), 460: ("pencilhatch", "Çizim ve Kenar", "pixel", ["Kalem", "Tarama", "Eskiz"], None),
 461: ("photocopy", "Renk ve Işık", "pixel", ["Fotokopi", "Baskı", "Eski"], None), 462: ("datacorrupt", "Bükme ve Bozulma", "pixel", ["Bozulma", "Dijital", "Glitch"], None),
}

NEW.update({
 463: ("debandfix", "Renk ve Işık", "pixel", ["Onarım", "Bant", "Geçiş"], None), 464: ("deinterlace", "Diğer", "pixel", ["Onarım", "Video", "Tarama"], None),
 465: ("deadpixel", "Diğer", "pixel", ["Onarım", "Piksel"], None), 466: ("smartfill", "Maske ve Anahtar", "pixel", ["Onarım", "Doldurma", "Maske"], None),
 467: ("dehaze", "Renk ve Işık", "pixel", ["Onarım", "Pus", "Netlik"], None), 469: ("rollingfix", "Bükme ve Bozulma", "pixel", ["Onarım", "Video", "Eğilme"], None),
 470: ("demoire", "Diğer", "pixel", ["Onarım", "Desen"], None), 471: ("deblock", "Diğer", "pixel", ["Onarım", "Sıkıştırma", "Blok"], None),
 472: ("dehalo", "Çizim ve Kenar", "pixel", ["Onarım", "Kenar", "Hale"], None),
 474: ("stringart", "Çizim ve Kenar", "pixel", ["Sanat", "İplik", "Çivi"], None), 475: ("lowpoly", "Çizim ve Kenar", "pixel", ["Sanat", "Çokgen", "Üçgen"], None),
 476: ("markerpen", "Çizim ve Kenar", "pixel", ["Sanat", "Kalem", "Keçeli"], None), 477: ("tornpaper", "Çizim ve Kenar", "pixel", ["Sanat", "Kolaj", "Kâğıt"], None),
 478: ("quilling", "Çizim ve Kenar", "pixel", ["Sanat", "Kâğıt", "Kıvırma"], None), 479: ("origami", "Çizim ve Kenar", "pixel", ["Sanat", "Kâğıt", "Katlama"], None),
 480: ("sandart", "Çizim ve Kenar", "pixel", ["Sanat", "Kum", "Tanecik"], None), 481: ("scratchart", "Çizim ve Kenar", "pixel", ["Sanat", "Kazıma"], None),
 482: ("cubism", "Çizim ve Kenar", "pixel", ["Sanat", "Kübizm", "Geometri"], None), 483: ("paintbynumber", "Çizim ve Kenar", "pixel", ["Sanat", "Boyama", "Numara"], None),
 484: ("paperrelief", "Çizim ve Kenar", "pixel", ["Sanat", "Kâğıt", "Kabartma"], None),
 485: ("halation", "Renk ve Işık", "pixel", ["Işık", "Film", "Hale"], {"k": "yayilim", "mul": 1.5}), 486: ("lightwrap", "Renk ve Işık", "pixel", ["Işık", "Birleştirme"], None),
 487: ("lensdirt", "Renk ve Işık", "pixel", ["Işık", "Mercek", "Toz"], None), 488: ("relight", "Renk ve Işık", "pixel", ["Işık", "Aydınlatma", "Normal"], None),
 489: ("normalmap", "Renk ve Işık", "pixel", ["Normal", "Harita", "Yükseklik"], None), 490: ("uvmap", "Bükme ve Bozulma", "pixel", ["UV", "Eşleme", "Doku"], None),
 491: ("floorshadow", "Renk ve Işık", "pixel", ["Gölge", "Zemin"], {"box": 0.6}), 492: ("floorreflect", "Renk ve Işık", "pixel", ["Yansıma", "Zemin"], {"box": 0.8}),
 493: ("freqsep", "Renk ve Işık", "pixel", ["Rötuş", "Frekans"], None), 494: ("colormatch", "Renk ve Işık", "pixel", ["Renk", "Eşleme", "Referans"], None),
 495: ("exposurefuse", "Renk ve Işık", "pixel", ["Pozlama", "HDR", "Birleştirme"], None),
})
# Tek karelik motorda karşılığı olmayan (zaman/analiz isteyen) ayarlar gizlenir; seçenekler yalnız çalışanlarla sınırlanır
HIDE = {"deinterlace": ["cikisHizi", "sahneKesiKoru"], "deadpixel": ["zamansalDogr", "dogrulamSure"], "smartfill": ["zamanTuta", "kareAral"], "dehaze": ["karelerArasDeng"],
        "rollingfix": ["hareketKayn", "okumaSure"], "deblock": ["zamansalDeng"], "uvmap": ["eslemeYont", "orneklem"], "colormatch": ["referansZama", "zamansalYumu"],
        "exposurefuse": ["otomatikHiza", "hayaletGoruAzal"], "datacorrupt": ["oncekiKareTasi", "kareHafi", "sahneDegiHafi"], "globe3d": [], "flagpole3d": [], "gear3d": ["baskaDislBagl", "baglantiDisl", "donusHiziDis"],
        "depthparallax": [], "volumelight": []}
TRIM = {("smartfill", "yontem"): 2, ("deinterlace", "alanSira"): 3}
NEW.update({
 508: ("maze", "Prosedürel", "gen", ["Desen", "Labirent"], None), 509: ("truchet", "Prosedürel", "pixel", ["Desen", "Karo"], None),
 510: ("plantgrow", "Prosedürel", "gen", ["Bitki", "Büyüme", "Dal"], {"box": 0.5}), 511: ("guilloche", "Prosedürel", "gen", ["Desen", "Banknot", "Eğri"], {"box": 0.3}),
 512: ("interference", "Prosedürel", "pixel", ["Desen", "Dalga"], None), 513: ("flowfield", "Prosedürel", "gen", ["Akış", "Parçacık", "Desen"], None),
 515: ("snowflake", "Prosedürel", "gen", ["Kar", "Kristal", "Simetri"], {"box": 0.3}), 516: ("ornament", "Prosedürel", "pixel", ["Desen", "Süsleme", "Geometri"], None),
 517: ("fractalpath", "Prosedürel", "gen", ["Fraktal", "Eğri", "Çizim"], None),
 520: ("connector", "Diğer", "gen", ["Çizgi", "Bağlantı", "Ok"], {"box": 1.0}), 521: ("measurearrow", "Diğer", "gen", ["Ölçü", "Ok", "Sayı"], {"box": 0.5}),
 524: ("reliefmap", "Renk ve Işık", "pixel", ["Harita", "Kabartma", "Yükseklik"], None), 525: ("mapproject", "Bükme ve Bozulma", "pixel", ["Harita", "Projeksiyon"], None),
 528: ("morphimg", "Geçiş", "pixel", ["Dönüşüm", "Biçim", "Geçiş"], None),
 529: ("lathe3d", "3B", "3d", ["3B", "Döndürme", "Model"], {"box": 0.45}), 533: ("pointcloud", "3B", "3d", ["3B", "Nokta", "Derinlik"], {"box": 0.45}),
 537: ("volslices", "Tekrar", "repeat", ["Dilim", "Derinlik", "Katman"], {"box": 0.3}), 539: ("scatter3d", "Tekrar", "repeat", ["Saçılım", "3B", "Kopya"], {"box": 1.0}),
 502: ("ropephys", "Simülasyon", "gen", ["İp", "Fizik", "Sarkma"], {"box": 0.6}), 503: ("clothphys", "Simülasyon", "pixel", ["Kumaş", "Fizik", "Rüzgâr"], {"box": 0.25}),
})
HIDE.update({"lathe3d": ["profilKayn", "profiliDuze", "acisalDili", "profilOrne", "uclariKapa", "yuzeyiYumu"], "pointcloud": ["kaynakTuru", "derinlikTest"], "morphimg": ["esNoktEkle", "esNoktKald", "agAyri", "agiGost"],
  "mapproject": [], "reliefmap": ["cikti", "agAyri"], "fractalpath": ["koseYumu"], "flowfield": [], "maze": ["cozumYoluGost"], "scatter3d": ["kopyalanNesn", "yuzeyMode"],
  "volslices": [], "clothphys": ["sabitPimEkle"], "ropephys": ["baslangiKatm", "bitisKatm"], "measurearrow": ["birimEtik"], "connector": [], "plantgrow": []})
TRIM.update({("fractalpath", "yolTuru"): 1, ("mapproject", "kaynakProj"): 2, ("reliefmap", "cikti"): 1, ("clothphys", "sabitKena"): 4, ("pointcloud", "kaynakTuru"): 2})
NEW.update({
 540: ("compressor", "Ses", "audio-fx", ["Ses", "Dinamik"], None), 541: ("limiter", "Ses", "audio-fx", ["Ses", "Dinamik"], None), 542: ("noisegate", "Ses", "audio-fx", ["Ses", "Gürültü"], None),
 543: ("deesser", "Ses", "audio-fx", ["Ses", "Konuşma"], None), 544: ("pitchshift", "Ses", "audio-fx", ["Ses", "Perde"], None), 545: ("voicechar", "Ses", "audio-fx", ["Ses", "Formant", "Karakter"], None),
 546: ("audiodenoise", "Ses", "audio-fx", ["Ses", "Gürültü", "Temizlik"], None), 547: ("ducking", "Ses", "audio-fx", ["Ses", "Müzik", "Konuşma"], None), 548: ("stereowide", "Ses", "audio-fx", ["Ses", "Stereo"], None),
 549: ("robotvoice", "Ses", "audio-fx", ["Ses", "Robot", "Vocoder"], None), 550: ("audiodistort", "Ses", "audio-fx", ["Ses", "Bozulma"], None),
})
HIDE.update({"limiter": ["gercekTepe", "stereoBagl", "otomatikGeciTela"], "audiodenoise": ["profilYont"], "ducking": ["otomatikGeciTela"], "pitchshift": ["sesKaraKoru", "kaynakTuru"], "voicechar": ["kalite"]})
NEW.update({
 498: ("springchain", "Taşı ve Dönüştür", "xform", ["Fizik", "Yay", "Takip"], None), 501: ("collide", "Taşı ve Dönüştür", "xform", ["Fizik", "Sekme", "Yerçekimi"], None),
 504: ("softbody", "Taşı ve Dönüştür", "xform", ["Fizik", "Jöle", "Esneme"], None), 505: ("motionpath", "Diğer", "special", ["Yol", "İz", "Hareket"], None),
 506: ("flock", "Tekrar", "special", ["Sürü", "Kopya", "Fizik"], None), 518: ("lipsync", "Countryball", "rig", ["Ağız", "Ses", "Konuşma"], None),
})
HIDE.update({"softbody": ["agAyri"], "lipsync": ["eslemeModu"], "motionpath": ["koordina"]})
NEW.update({507: ("reactdiff", "Prosedürel", "pixel", ["Desen", "Benzetim", "Turing"], None)})
NEW.update({
 473: ("framerepair", "Zaman", "pixel", ["Onarım", "Kare", "Video"], None), 526: ("cinemagraph", "Zaman", "pixel", ["Hareketli fotoğraf", "Maske"], None),
 527: ("motionmagnify", "Zaman", "pixel", ["Hareket", "Büyütme"], None), 496: ("puppetpin", "Bükme ve Bozulma", "pixel", ["Kukla", "Pim"], {"box": 0.2}),
 522: ("animchart", "Diğer", "gen", ["Grafik", "Sütun", "Pasta"], None), 523: ("timeline", "Diğer", "gen", ["Tarih", "Zaman çizelgesi"], None),
 497: ("ikchain", "Taşı ve Dönüştür", "rig", ["Kemik", "Ters kinematik"], None), 514: ("organicgrow", "Prosedürel", "gen", ["Büyüme", "Organik"], None),
 519: ("karaoke", "Metin", "text", ["Metin", "Karaoke", "Altyazı"], None), 536: ("explodegroup", "Taşı ve Dönüştür", "rig", ["Parça", "Ayrıştırma"], None),
})
HIDE.update({"framerepair": ["gecerliKareIsar", "isaretiKald", "kareSeci", "enUzunBosl"], "cinemagraph": ["maskeyiCiz", "dongu", "donguSure", "donguKari"], "motionmagnify": ["altFrek", "ustFrek", "yontem", "sahneKesiSifi", "kalite", "etkiMask"],
  "puppetpin": ["agAyri", "agGeni", "pimEkle", "pimiKald"], "animchart": ["veriDuze"], "timeline": ["olayEkle"], "ikchain": ["eklemEkle"], "karaoke": ["altyaziDosy", "zamanIsarEkle"], "explodegroup": ["parcaSeci"], "organicgrow": ["baslangi"]})
for _n in (496,):
    pass
NEW.update({
 530: ("loftprofiles", "3B", "3d", ["3B", "Profil", "Yüzey"], {"box": 0.45}), 531: ("sweeppath", "3B", "3d", ["3B", "Yol", "Boru"], {"box": 0.5}),
 532: ("wireframe3d", "3B", "3d", ["3B", "Tel kafes"], {"box": 0.45}), 534: ("sectionview", "3B", "3d", ["3B", "Kesit"], {"box": 0.45}),
 535: ("csgcards", "3B", "3d", ["3B", "Birleştirme", "Boole"], {"box": 0.45}), 538: ("decal3d", "3B", "3d", ["3B", "Çıkartma"], {"box": 0.45}),
})
HIDE.update({"loftprofiles": ["profilEkle", "cevreOrne", "araDili"], "sweeppath": ["ozelKesi", "kesitOrne", "yolOrne"], "wireframe3d": ["model", "keskinliEsig", "gizliKenaGost", "gizliKenaOpak"], "sectionview": ["model", "duzlemKila"],
  "csgcards": ["birinciMode", "girislerGoruTut", "normalDuze", "geometriDogr"], "decal3d": ["hedefMode", "yontem"]})
TRIM.update({("sweeppath", "kesit"): 3})
NEW.update({468: ("stabilize", "Diğer", "pixel", ["Video", "Sabitleme", "Kamera"], {"box": 0.1})})
HIDE.update({"stabilize": ["hareketMode", "izlemeMask", "hareketiAnalEt", "sahneKesiSifi"]})
NEW.update({499: ("pointtrack", "Taşı ve Dönüştür", "rig", ["Takip", "Nokta", "Video"], None), 500: ("surfacetrack", "Taşı ve Dönüştür", "rig", ["Takip", "Yüzey", "Video"], None)})
HIDE.update({"pointtrack": ["yon", "guvenEsig", "analizEt", "anahtarKareDonu", "yumusatm"], "surfacetrack": ["yuzeyKoseSec", "guvenEsig", "ortulenBolgYok", "analizEt", "yuzeySiniKirp", "koseleriDuze"]})
TRIM.update({("surfacetrack", "donusumMode"): 2})
READY2 = set(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "ready2.txt")).read().split()) if os.path.exists(os.path.join(os.path.dirname(os.path.abspath(__file__)), "ready2.txt")) else set()
_POS = _re.compile(r"(merkez|konum|ufuk|nokta|kök|başlangıç$|bitiş$|bağlantı|hedef)", _re.I)
MATS = ["Beyaz kâğıt", "Renkli kâğıt", "Kraft kâğıt", "Karton", "Parşömen", "Keçe"]
_BASE3D = [copy.deepcopy(p) for p in _BY["cube"]["params"] if p.get("g") in ("3B Dönüşüm", "Kamera", "Işık ve Gölge", "Malzeme")]
def _conv(p):
    q = {k: v for k, v in p.items() if k not in ("code",)}
    if q.get("two") and q.get("unit") in ("%", "") and _POS.search(q["l"]): q["unit"] = "box%"; q["min"], q["max"] = -100, 200
    if q["kind"] in ("toggle", "choice"): q["anim"] = "step"
    if q["kind"] in ("source", "button", "text", "info"): q["anim"] = "no"
    if q["kind"] == "button" and not q.get("reset"): q["hideUi"] = True
    if q["kind"] == "source" and q["k"] in ("modelGrub",): q["multi"] = True
    if q["kind"] == "info" and p.get("code") == "Ş": q.update(kind="choice", min=0, max=len(MATS) - 1, def_=0, opts=list(MATS), anim="step")  # işlevi tanımlı olmayan eylem düğmeleri gösterilmez
    return q
for _t in ("reverse", "basstreble", "delay", "flanger", "filter", "modulator", "parameq", "reverb", "stereo", "tone"):
    _BY[_t]["ready"] = True  # telefon ses motoru (AudioFx.kt)
for n, (t, cat, kind, tags, pad) in NEW.items():
    s = _SP2[str(n)]
    if t in _BY:  # aynı tür daha önce tanımlıysa (ör. motorun beklediği kara delik) yeni tanım onun yerine geçer
        E.remove(_BY[t])
    fx(t, s["name"], "", _C[cat], kind, s["desc"] or s["name"], tags, [_conv(p) for p in s["params"]], pad=pad, heavy=kind == "3d")
    e = E[-1]; e["n"] = n; _BY[t] = e
    if kind == "3d":
        have = {p["k"] for p in e["params"]}; e["params"] += [copy.deepcopy(p) for p in _BASE3D if p["k"] not in have]
    if s.get("teach"): e["teach"] = s["teach"]
    e["ready"] = t in READY2
    e["hidden"] = not e["ready"]
    e["presets"] = []
    for p in e["params"]:
        if p["k"] in HIDE.get(t, []): p["hideUi"] = True
        if (t, p["k"]) in TRIM: p["opts"] = p["opts"][:TRIM[(t, p["k"])]]; p["max"] = len(p["opts"]) - 1; p["def_"] = min(p["def_"], p["max"])
NP = {}
