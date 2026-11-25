# After Effects listesinden eksik kalanlar + Ses kategorisi (catalog.py içinden çalıştırılır). Toplam 350.
CATS += ["Ses"]
SND = 15

# ---------- Bulanıklık ----------
c = 2
fx("unsharp", "Bulanık Maske", "Unsharp Mask", c, "pixel", "Görüntüyü bulanık kopyasıyla karşılaştırıp kontrollü keskinleştirir.", ["Netlik", "Fotoğraf"],
   [PCT("amount", "Miktar", 100, 0, 500), J("rad", "Yarıçap", 0.3, 50, 3, 0.1, 0.05), J("thr", "Eşik", 0, 255, 2, 1, 0.5)],
   passes=[{"blur": "src", "r": {"k": "rad", "mul": 1}, "out": "B"}, {"fs": "unsharp", "aux": {"u_aux": "B"}}])
fx("compoundblur", "Bileşik Bulanıklık", "Compound Blur", c, "pixel", "Bulanıklığı bir haritaya göre değiştirir: kenarlara, merkeze ya da parlak yerlere daha çok.", ["Bulanık"],
   [J("amount", "En çok", 0, 60, 14, 0.5, 0.2), CH("map", "Harita", ["Kenarlar", "Merkez", "Parlak yerler", "Koyu yerler", "Üstten alta"])],
   passes=[{"blur": "src", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "compoundblur", "aux": {"u_aux": "B"}}])

# ---------- Renk ve Işık ----------
c = 0
fx("autocolor", "Otomatik Renk", "Auto Color", c, "pixel", "Renk kaymasını kendiliğinden düzeltir, beyazı beyaz yapar.", ["Renk", "Otomatik", "Fotoğraf"], [PCT("amount", "Güç", 100)])
fx("huesat", "Ton / Doygunluk", "Hue/Saturation", c, "pixel", "Ton, doygunluk ve açıklığı birlikte ayarlar; istersen tek renge boyar.", ["Renk"],
   [A("hue", "Ton", 0), J("sat", "Doygunluk", -100, 100, 25, 1, 0.5), J("lit", "Açıklık", -100, 100, 0, 1, 0.5), T("colorize", "Renklendir", 0)])
fx("gammagain", "Gama / Taban / Kazanç", "Gamma/Pedestal/Gain", c, "pixel", "Her kanalın siyah seviyesini, orta tonunu ve parlaklığını ayrı ayarlar.", ["Renk", "Kanal"],
   [J("gamma", "Gama", 0.1, 4, 1, 0.01, 0.005), J("ped", "Taban", -1, 1, 0, 0.01, 0.005), J("gain", "Kazanç", 0, 4, 1.15, 0.01, 0.005), CH("ch", "Kanal", ["Hepsi", "Kırmızı", "Yeşil", "Mavi"])])
fx("lumetri", "Lumetri Renk", "Lumetri Color", c, "pixel", "Profesyonel renk düzeltme: beyaz dengesi, ışık, renk ve görünüm tek yerde.", ["Renk", "Sinema", "Fotoğraf"],
   [J("temp", "Sıcaklık", -100, 100, 0, 1, 0.5), J("tint", "Renk tonu", -100, 100, 0, 1, 0.5), J("exp", "Pozlama", -5, 5, 0, 0.01, 0.01), J("con", "Kontrast", -100, 100, 10, 1, 0.5),
    J("hi", "Açık tonlar", -100, 100, -10, 1, 0.5), J("sh", "Gölgeler", -100, 100, 10, 1, 0.5), J("wh", "Beyazlar", -100, 100, 0, 1, 0.5), J("bl", "Siyahlar", -100, 100, 0, 1, 0.5),
    J("sat", "Doygunluk", 0, 200, 110, 1, 0.5), J("vib", "Canlılık", -100, 100, 10, 1, 0.5), J("fade", "Soluk film", 0, 100, 0, 1, 0.5), J("sharp", "Keskinlik", 0, 100, 0, 1, 0.5), J("vign", "Vinyet", -100, 100, 0, 1, 0.5)],
   [P("SN", "Sinema", {"con": 25, "sat": 90, "fade": 15, "vign": -30, "temp": 10}), P("YZ", "Yaz", {"temp": 30, "exp": 0.3, "vib": 40}), P("KS", "Kış", {"temp": -40, "sat": 80, "hi": 20})])
fx("lut", "Hazır Renk Görünümü", "Apply Color LUT", c, "pixel", "Film ve fotoğraf görünümleri (LUT) tek dokunuşla.", ["Renk", "Sinema", "Film"],
   [CH("look", "Görünüm", ["Sıcak film", "Soğuk film", "Turkuaz-turuncu", "Soluk retro", "Gece mavisi", "Altın saat", "Kodak benzeri", "Siyah beyaz film", "Neon", "Pastel"]), PCT("mix", "Yoğunluk", 100)])
fx("bwmix", "Siyah Beyaz Karıştırıcı", "Black & White Mixer", c, "pixel", "Siyah beyaza çevirirken her rengin ne kadar açık ya da koyu olacağını seçersin.", ["Renk", "Fotoğraf", "Retro"],
   [J("r", "Kırmızılar", -200, 300, 40, 1, 0.5), J("y", "Sarılar", -200, 300, 60, 1, 0.5), J("g", "Yeşiller", -200, 300, 40, 1, 0.5), J("cy", "Camgöbekleri", -200, 300, 60, 1, 0.5), J("b", "Maviler", -200, 300, 20, 1, 0.5), J("m", "Morlar", -200, 300, 80, 1, 0.5), C("tint", "Ton rengi", "#FFFFFF")])
fx("changecolor", "Rengi Ayarla", "Change Color", c, "pixel", "Seçtiğin rengin tonunu, doygunluğunu ve açıklığını değiştirir.", ["Renk"],
   [C("key", "Renk", "#2F7BF6"), A("hue", "Ton", 60), J("sat", "Doygunluk", -100, 100, 0, 1, 0.5), J("lit", "Açıklık", -100, 100, 0, 1, 0.5), PCT("tol", "Tolerans", 30), PCT("soft", "Yumuşaklık", 20)])

# ---------- Bükme ----------
c = 3
fx("opticscomp", "Mercek Düzeltme", "Optics Compensation", c, "pixel", "Geniş açı objektif bükülmesi ekler ya da düzeltir.", ["Mercek", "Fotoğraf"], [J("fov", "Görüş açısı", -100, 100, 40, 1, 0.5), XY("center", "Merkez", 0, 0), T("rev", "Düzelt", 0)])
fx("bender", "Kavis", "Bender", c, "pixel", "Katmanı bir ucundan tutup kıvırır; uçtan uca yumuşak kavis.", ["Bükme"], [J("amount", "Kavis", -100, 100, 40, 1, 0.5), CH("style", "Biçim", ["Yay", "Keskin", "S"]), CH("dir", "Yön", ["Yukarı", "Yana"])], pad={"add": 60})

# ---------- Prosedürel ----------
c = 4
fx("fractalset", "Fraktal", "Fractal (Mandelbrot/Julia)", c, "gen", "Sonsuz ayrıntılı Mandelbrot ve Julia fraktalları; yakınlaşarak canlandır.", ["Matematik", "Psikedelik", "Desen"],
   [CH("set", "Tür", ["Mandelbrot", "Julia"]), J("zoom", "Yakınlaşma", 0.1, 1e5, 1, 0.01, 0.01), XY("center", "Merkez", -0.5, 0, -3, 3, 0.001), XY("jc", "Julia sabiti", -0.7, 0.27, -2, 2, 0.001), J("iter", "Ayrıntı", 10, 500, 120, 1, 0.5), J("cycle", "Renk akışı", -5, 5, 0.3, 0.01, 0.01)] + G())
fx("cellpattern", "Hücre Deseni", "Cell Pattern", c, "gen", "Kabarcık, kristal, plaka gibi hücre desenleri.", ["Desen", "Doğa", "Doku"],
   [CH("style", "Stil", ["Kabarcıklar", "Kristaller", "Plakalar", "Pikseller", "Statik"]), J("size", "Boyut", 4, 500, 40, 0.5, 0.2), J("speed", "Evrim", 0, 5, 0.4, 0.01, 0.01), PCT("contrast", "Kontrast", 100, 0, 300), C("c1", "Koyu", "#0B1430"), C("c2", "Açık", "#3FD0F0")] + G())

# ---------- Çizim ve Kenar (Stilize) ----------
c = 1
fx("thresholdrgb", "RGB Eşik", "Threshold RGB", c, "pixel", "Her renk kanalına ayrı eşik uygular; pop-art renkler.", ["Renk", "Grafik", "Retro"], [J("r", "Kırmızı eşik", 0, 255, 128, 1, 0.5), J("g", "Yeşil eşik", 0, 255, 128, 1, 0.5), J("b", "Mavi eşik", 0, 255, 128, 1, 0.5)])
fx("scatterpx", "Piksel Saçma", "Scatter", c, "pixel", "Pikselleri yakın çevresine rastgele dağıtır (buzlu, kumlu görünüm).", ["Doku", "Glitch"], [J("amount", "Miktar", 0, 100, 8, 0.5, 0.2), CH("dir", "Yön", ["Her yöne", "Yatay", "Dikey"]), T("anim", "Her karede değişsin", 1)], pad={"k": "amount", "mul": 1})
fx("repetile", "Kenar Tekrarı", "RepeTile", c, "repeat", "Katmanın kenarlarından dışarı doğru kopyalar ya da aynalar ekler.", ["Tekrar", "Döşeme"], [J("l", "Sol", 0, 2000, 60, 1, 0.5), J("r", "Sağ", 0, 2000, 60, 1, 0.5), J("u", "Üst", 0, 2000, 60, 1, 0.5), J("d", "Alt", 0, 2000, 60, 1, 0.5), CH("mode", "Tür", ["Tekrar", "Ayna", "Kenarı uzat"])], pad={"max": ["l", "r", "u", "d"]})
fx("burnfilm", "Film Yanması", "Burn Film", c, "pixel", "Sıcaktan yanan film şeridi gibi kenarları kızarıp delinir.", ["Retro", "Film", "Geçiş"], [PCT("prog", "Yanma", 40), J("scale", "Ölçek", 10, 1000, 100, 1, 0.5), XY("center", "Başlangıç", 0, 0)], [P("YN", "Yanarak kaybol", keys={"prog": [[-1.2, 0], [0, 100]]}, at="end")])
fx("blockload", "Blok Yükleme", "Block Load", c, "pixel", "Eski internet gibi önce iri bloklar, sonra net görüntü yüklenir.", ["Retro", "Geçiş", "Dijital"], [PCT("prog", "Yükleme", 50), T("scan", "Satır satır", 1)], [P("YK", "Yüklenerek gel", keys={"prog": [[0, 0], [1, 100]]})])

# ---------- Simülasyon ----------
c = SIM
fx("particleworld", "3B Parçacık Dünyası", "Particle World", c, "gen", "3B uzayda fışkıran, dönen ve kameraya göre derinliği olan parçacıklar.", ["Simülasyon", "Parçacık", "3B"],
   [XY("pos", "Kaynak", 0, 60), PCT("rate", "Sıklık", 60), J("vel", "Hız", 0, 2000, 260, 1, 0.5), J("grav", "Yerçekimi", -2000, 2000, 200, 1, 0.5), J("life", "Ömür", 0.1, 10, 2, 0.05, 0.02), CH("shape", "Parçacık", ["Işık noktası", "Yıldız", "Kalp", "Kare", "Katmanın kendisi"]), C("c1", "Renk 1", "#3FD0F0"), C("c2", "Renk 2", "#8F7CF0"), A("camY", "Kamera açısı", 20)])

# ---------- Zaman ----------
c = TIM
fx("speed", "Hız Değiştir", "Timewarp / Speed", c, "time", "Katmanın içindeki animasyonu ve videoyu yavaşlatır, hızlandırır ya da ters oynatır.", ["Zaman", "Hız", "Yavaş çekim"],
   [PCT("speed", "Hız", 50, -400, 400), T("rev", "Ters", 0), T("hold", "Sonda dur", 1)], [P("YC", "Yavaş çekim", {"speed": 30}), P("HZ", "Hızlı", {"speed": 250}), P("TR", "Ters oynat", {"speed": 100, "rev": 1})])

# ---------- Gürültü (Diğer kategorisinde) ----------
c = 11
fx("fractalnoise", "Fraktal Gürültü", "Fractal Noise", c, "gen", "After Effects'in meşhur gürültüsü: duman, bulut, sis, taş, su yüzeyi.", ["Doku", "Duman", "Doğa"],
   [CH("ftype", "Tür", ["Temel", "Türbülanslı", "Yumuşak", "Dinamik", "Kıvrımlı"]), T("inv", "Tersine çevir", 0), PCT("contrast", "Kontrast", 100, 0, 400), J("bright", "Parlaklık", -200, 200, 0, 1, 0.5), J("scale", "Ölçek", 10, 3000, 120, 1, 0.5),
    J("cplx", "Karmaşıklık", 1, 20, 6, 0.1, 0.05), J("evo", "Evrim (°/sn)", -720, 720, 60, 1, 0.5), XY("off", "Kaydır", 0, 0), CH("blendm", "Karıştırma", ["Kapla", "Çarp", "Ekran", "Kaplama", "Saydamlık"])])
fx("noisehls", "Renk Gürültüsü", "Noise HLS", c, "pixel", "Ton, açıklık ve doygunluğa ayrı ayrı gürültü ekler.", ["Gürültü", "Retro"], [PCT("hue", "Ton", 0), PCT("lit", "Açıklık", 20), PCT("sat", "Doygunluk", 20), J("size", "Tane", 1, 20, 1, 0.1, 0.05), J("speed", "Hız", 0, 60, 24, 1, 0.5)])
fx("denoise", "Gürültü Azalt", "Remove Grain", c, "pixel", "Kumlu ve karıncalı görüntüyü temizler, ayrıntıyı korur.", ["Gürültü", "Fotoğraf", "Video"], [PCT("amount", "Güç", 60), PCT("detail", "Ayrıntı koru", 50)])

# ---------- Kanal (Diğer) ----------
fx("arithmetic", "Kanal Aritmetiği", "Arithmetic", c, "pixel", "Renk kanallarına toplama, çarpma, fark gibi işlemler uygular.", ["Kanal", "Renk"],
   [CH("op", "İşlem", ["Ekle", "Çıkar", "Çarp", "Fark", "En az", "En çok", "Ve", "Veya", "Özel veya"]), J("r", "Kırmızı", 0, 255, 60, 1, 0.5), J("g", "Yeşil", 0, 255, 0, 1, 0.5), J("b", "Mavi", 0, 255, 120, 1, 0.5)])
fx("minimax", "En Az / En Çok", "Minimax", c, "pixel", "Her pikseli çevresindeki en açık ya da en koyu renkle değiştirir; şişirir ya da inceltir.", ["Kanal", "Kenar"],
   [CH("op", "İşlem", ["En çok (şişir)", "En az (incelt)", "En az sonra en çok", "En çok sonra en az"]), J("rad", "Yarıçap", 0, 20, 3, 1, 0.1), CH("ch", "Kanal", ["Renk ve saydamlık", "Sadece renk", "Sadece saydamlık"])], pad={"k": "rad", "mul": 1})
fx("blendorig", "Orijinalle Karıştır", "Blend with Original", c, "pixel", "Önceki efektlerin sonucunu katmanın efektsiz hâliyle bir karıştırma moduyla birleştirir.", ["Bileşim", "Kanal"],
   [CH("mode", "Mod", ["Normal", "Çarp", "Ekran", "Kaplama", "Fark", "Yalnız renk", "Yalnız ışık", "Ekle"]), PCT("mix", "Karışım", 50)], info="Efekt listesinde en sona koy.")

# ---------- Maske ve Anahtar ----------
c = 8
fx("keylight", "Gelişmiş Kroma", "Keylight", c, "pixel", "Profesyonel yeşil/mavi perde silme: perde dengesi, siyah/beyaz kırpma, taşma temizleme.", ["Maske", "Anahtar", "Video"],
   [C("key", "Perde rengi", "#22B14C"), PCT("gain", "Perde gücü", 100, 0, 200), PCT("bal", "Perde dengesi", 50), PCT("clipb", "Siyah kırp", 0), PCT("clipw", "Beyaz kırp", 100), J("shrink", "Kenar daralt", -10, 10, 0, 0.1, 0.05), J("soft", "Kenar yumuşat", 0, 10, 0.5, 0.1, 0.05), PCT("despill", "Taşma temizle", 70)])
fx("colorkey", "Renk Anahtarı", "Color Key", c, "pixel", "Seçilen rengi ve yakınlarını saydam yapar (basit).", ["Maske", "Anahtar"], [C("key", "Renk", "#FFFFFF"), PCT("tol", "Tolerans", 10), J("thin", "Kenar incelt", -10, 10, 0, 0.1, 0.05), J("feather", "Kenar yumuşat", 0, 20, 1, 0.1, 0.05)])
fx("extract", "Ayıkla", "Extract", c, "pixel", "Belli bir parlaklık aralığını tutar, gerisini saydam yapar.", ["Maske", "Anahtar"], [J("lo", "Siyah noktası", 0, 255, 30, 1, 0.5), J("hi", "Beyaz noktası", 0, 255, 255, 1, 0.5), J("lsoft", "Siyah yumuşak", 0, 255, 20, 1, 0.5), J("hsoft", "Beyaz yumuşak", 0, 255, 0, 1, 0.5), T("inv", "Tersine çevir", 0)])

# ---------- Diğer ----------
c = 11
fx("fog", "Sis", "Fog", c, "gen", "Aşağıdan yükselen ya da uzakta yoğunlaşan, kıpırdayan sis.", ["Doğa", "Duman", "Atmosfer"], [PCT("dens", "Yoğunluk", 60), PCT("height", "Yükseklik", 50), J("speed", "Hız", 0, 5, 0.3, 0.01, 0.01), C("col", "Renk", "#DCE6F5"), CH("dir", "Yön", ["Alttan", "Üstten", "Her yer"])])
fx("reorient360", "360 Küre Döndürme", "VR Rotate Sphere", c, "pixel", "360 derece (eşdikdörtgen) videoyu ya da görseli üç eksende döndürür.", ["360", "VR", "3B"], [A("yaw", "Sağ-sol", 30), A("pitch", "Yukarı-aşağı", 0), A("roll", "Yatma", 0)])
fx("tinyplanet", "Küçük Gezegen", "Tiny Planet", c, "pixel", "Panoramayı ya da manzarayı yuvarlak bir küçük gezegene çevirir.", ["360", "Bükme", "Fotoğraf"], [J("zoom", "Yakınlık", 0.1, 5, 1, 0.01, 0.01), A("rot", "Dönme", 0), T("inv", "Tünel (ters)", 0)], [P("DN", "Dönen gezegen", keys={"rot": [[0, 0], [4, 360]]})])
fx("chromaber", "Kromatik Sapma", "Chromatic Aberration", c, "pixel", "Ucuz objektif gibi kenarlarda renk saçakları.", ["Mercek", "Retro", "Glitch"], [J("amount", "Miktar", 0, 50, 6, 0.1, 0.05), XY("center", "Merkez", 0, 0), T("radial", "Kenarlarda artsın", 1)], pad={"k": "amount", "mul": 1})
fx("pathtext", "Yol Üzerinde Yazı", "Path Text", 10, "text", "Yazıyı bir dairenin, yayın ya da dalganın üzerine dizer.", ["Metin", "Şekil"],
   [CH("shape", "Yol", ["Daire", "Yay", "Dalga", "Spiral"]), J("rad", "Yarıçap / Boy", 10, 3000, 200, 1, 0.5), J("curve", "Kavis", -100, 100, 60, 1, 0.5), PCT("start", "Başlangıç", 0, -100, 200), J("spin", "Dönme (°/sn)", -720, 720, 0, 1, 0.5), T("flip", "İçe dönük", 0)], info=TI)

# ---------- Ses (ses ve video katmanlarında) ----------
c = SND
SI = "Ses ve video katmanlarının sesine uygulanır."
fx("reverse", "Ters Oynat", "Backwards", c, "audio-fx", "Sesi sondan başa çalar.", ["Ses"], [], info=SI)
fx("basstreble", "Bas ve Tiz", "Bass & Treble", c, "audio-fx", "Kalın ve ince sesleri ayrı ayrı güçlendirir ya da kısar.", ["Ses", "EQ"], [J("bass", "Bas (dB)", -24, 24, 6, 0.5, 0.2), J("treble", "Tiz (dB)", -24, 24, 0, 0.5, 0.2)], info=SI)
fx("delay", "Gecikme / Yankı", "Delay", c, "audio-fx", "Sesin gecikmeli tekrarlarını ekler.", ["Ses", "Yankı"], [J("time", "Gecikme (sn)", 0.01, 2, 0.3, 0.01, 0.005), PCT("fb", "Geri besleme", 40, 0, 95), PCT("mix", "Karışım", 35)], info=SI)
fx("flanger", "Flanş ve Koro", "Flange & Chorus", c, "audio-fx", "Sese dalgalanan, geniş ve uzay gibi bir katman verir.", ["Ses"], [CH("mode", "Tür", ["Flanş", "Koro"]), J("rate", "Hız (Hz)", 0.05, 10, 0.5, 0.01, 0.01), PCT("depth", "Derinlik", 50), PCT("mix", "Karışım", 50)], info=SI)
fx("filter", "Alçak / Yüksek Geçiren", "High-Low Pass", c, "audio-fx", "Belli bir frekansın altını ya da üstünü keser (telefon sesi, duvar arkası).", ["Ses", "EQ"], [CH("mode", "Tür", ["Alçak geçiren (boğuk)", "Yüksek geçiren (ince)"]), J("freq", "Kesim (Hz)", 20, 20000, 800, 1, 5)], [P("TL", "Telefon sesi", {"mode": 1, "freq": 900}), P("DV", "Duvar arkası", {"mode": 0, "freq": 400})], info=SI)
fx("modulator", "Modülatör", "Modulator", c, "audio-fx", "Sesin şiddetini ya da perdesini titretir (tremolo, vibrato).", ["Ses"], [CH("mode", "Tür", ["Şiddet (tremolo)", "Perde (vibrato)"]), J("rate", "Hız (Hz)", 0.1, 30, 5, 0.05, 0.02), PCT("depth", "Derinlik", 50)], info=SI)
fx("parameq", "Parametrik EQ", "Parametric EQ", c, "audio-fx", "Üç ayrı frekans bandını yükseltir ya da kısar.", ["Ses", "EQ"],
   [J("f1", "Bant 1 (Hz)", 20, 20000, 120, 1, 5), J("g1", "Kazanç 1 (dB)", -24, 24, 3, 0.5, 0.2), J("f2", "Bant 2 (Hz)", 20, 20000, 1000, 1, 5), J("g2", "Kazanç 2 (dB)", -24, 24, 0, 0.5, 0.2), J("f3", "Bant 3 (Hz)", 20, 20000, 6000, 1, 5), J("g3", "Kazanç 3 (dB)", -24, 24, 2, 0.5, 0.2), J("q", "Genişlik", 0.1, 10, 1, 0.01, 0.01)], info=SI)
fx("reverb", "Yankılanma", "Reverb", c, "audio-fx", "Sesi bir odada, salonda ya da mağarada çalınıyor gibi yapar.", ["Ses", "Yankı"], [CH("room", "Ortam", ["Oda", "Salon", "Kilise", "Mağara"]), PCT("size", "Boyut", 50), PCT("damp", "Sönümleme", 50), PCT("mix", "Karışım", 30)], info=SI)
fx("stereo", "Stereo Mikser", "Stereo Mixer", c, "audio-fx", "Sesi sağa sola kaydırır, sol ve sağ kanalı ayarlar.", ["Ses"], [J("pan", "Sol / Sağ", -100, 100, 0, 1, 0.5), PCT("l", "Sol düzey", 100, 0, 200), PCT("r", "Sağ düzey", 100, 0, 200), T("swap", "Kanalları değiştir", 0)], [P("GZ", "Sağdan sola gez", keys={"pan": [[0, 100], [2, -100]]})], info=SI)
fx("tone", "Ton Üretici", "Tone", c, "audio-fx", "Belirli frekansta bip, uğultu ya da akor sesi üretir.", ["Ses", "Üret"], [CH("wave", "Dalga", ["Sinüs", "Kare", "Üçgen", "Testere"]), J("freq", "Frekans (Hz)", 20, 8000, 440, 1, 1), PCT("vol", "Ses düzeyi", 30), T("chord", "Akor (üç ses)", 0)], info="Katmanın kendisi ses üretir; bir ses katmanına ya da herhangi bir katmana ekleyebilirsin.")
