# Alight Motion listesindeki eksikler (51) + birleştirmeler (20 efekt başka efektin içine girer) → tam 400 efekt
# ---------- Bulanıklık ----------
c = 2
fx("chromvortex", "Renkli Girdap Bulanıklığı", "Chromatic Vortex Blur", c, "pixel", "Dönerek bulanıklaşırken renkleri kırmızı, yeşil, mavi diye ayırır.", ["Bulanık", "Renk", "Psikedelik"], [A("amount", "Açı", 20), PCT("split", "Renk ayrımı", 60), XY("center", "Merkez", 0, 0)])
fx("chromzoom", "Renkli Yakınlaştırma Bulanıklığı", "Chromatic Zoom Blur", c, "pixel", "Merkezden dışarı bulanıklaşırken renk saçakları oluşturur.", ["Bulanık", "Renk", "Hız"], [PCT("amount", "Miktar", 25), PCT("split", "Renk ayrımı", 60), XY("center", "Merkez", 0, 0)], pad={"add": 20})
fx("innerblur", "İç Bulanıklık", "Inner Blur", c, "pixel", "Şeklin kenarını keskin bırakıp sadece içini bulanıklaştırır.", ["Bulanık", "Kenar"], [J("amount", "Miktar", 0, 60, 10, 0.5, 0.2), J("edge", "Kenar payı", 0, 50, 4, 0.5, 0.2)],
   passes=[{"blur": "src", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "innerblur", "aux": {"u_aux": "B"}}])
fx("linstreaks", "Doğrusal İzler", "Linear Streaks", c, "pixel", "Görüntüyü bir yönde, keskin uzayan izler hâlinde sürükler.", ["Bulanık", "Hız", "Glitch"], [J("len", "Uzunluk", 0, 400, 60, 0.5, 0.2), A("ang", "Açı", 0), PCT("fade", "Solma", 60), T("bright", "Sadece parlaklar", 0)], pad={"k": "len", "mul": 1})
fx("maskblur", "Maske Bulanıklığı", "Mask Blur", c, "pixel", "Bir şekil maskesinin içini (ya da dışını) bulanıklaştırır; yüz bulanıklaştırma, sansür.", ["Bulanık", "Maske", "Sansür"],
   [CH("shape", "Şekil", ["Daire", "Dikdörtgen", "Yuvarlak dikdörtgen"]), XY("pos", "Konum", 0, 0), J("w", "Genişlik", 1, 3000, 120, 1, 0.5), J("h", "Yükseklik", 1, 3000, 120, 1, 0.5), J("amount", "Bulanıklık", 0, 60, 14, 0.5, 0.2), J("feather", "Kenar yumuşaklığı", 0, 200, 10, 0.5, 0.2), T("inv", "Dışını bulanıklaştır", 0)],
   passes=[{"blur": "src", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "maskblur", "aux": {"u_aux": "B"}}])
fx("spinstreaks", "Dönme İzleri", "Spin Streaks", c, "pixel", "Parlak yerler merkez etrafında dairesel izler bırakır.", ["Işık", "Hız", "Döndür"], [A("amount", "Açı", 25), XY("center", "Merkez", 0, 0), J("thr", "Eşik", 0, 100, 40, 1, 0.5), PCT("str", "Güç", 100, 0, 300)])
fx("streakstrips", "Şerit İzler", "Streak Strips", c, "pixel", "Görüntüyü ince şeritlere bölüp her şeridi farklı uzunlukta sürükler.", ["Glitch", "Hız"], [J("count", "Şerit", 2, 200, 30, 1, 0.1), J("len", "Uzunluk", 0, 600, 80, 0.5, 0.2), A("ang", "Açı", 0), J("speed", "Değişim hızı", 0, 20, 2, 0.1, 0.05), J("seed", "Tohum", 0, 100, 1, 1, 0.2)], pad={"k": "len", "mul": 1})
fx("swirlblur", "Girdap Bulanıklığı", "Swirl Blur", c, "pixel", "Merkezde güçlü, kenarda azalan girdap biçimli bulanıklık.", ["Bulanık", "Döndür"], [A("amount", "Açı", 30), PCT("rad", "Yarıçap", 70, 0, 300), XY("center", "Merkez", 0, 0)])
fx("warpblur", "Bükme Bulanıklığı", "Warp Blur", c, "pixel", "Akışkan bir gürültünün yönünde, kıvrımlı bulanıklık.", ["Bulanık", "Akışkan"], [J("amount", "Miktar", 0, 100, 20, 0.5, 0.2), J("scale", "Ölçek", 10, 1000, 120, 1, 0.5), J("speed", "Hız", 0, 5, 0.5, 0.01, 0.01)])
fx("zoomstreaks", "Yakınlaştırma İzleri", "Zoom Streaks", c, "pixel", "Parlak yerlerden merkezden dışarı keskin ışık izleri.", ["Işık", "Hız"], [PCT("len", "Uzunluk", 40), XY("center", "Merkez", 0, 0), J("thr", "Eşik", 0, 100, 40, 1, 0.5), PCT("str", "Güç", 100, 0, 300)], pad={"add": 30})
# ---------- Renk ve Işık ----------
c = 0
fx("darkglow", "Karanlık Parlama", "Dark Glow", c, "pixel", "Koyu yerlerin çevresine karanlık bir hale yayar; gizemli, dramatik görünüm.", ["Gölge", "Dramatik"], [J("amount", "Yarıçap", 0, 60, 14, 0.5, 0.2), J("thr", "Eşik", 0, 100, 35, 1, 0.5), PCT("str", "Güç", 100, 0, 300)],
   passes=[{"fs": "darkglow_a", "out": "A"}, {"blur": "A", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "darkglow_c", "aux": {"u_aux": "B"}}])
fx("lightglow", "Işık Parlaması", "Light Glow", c, "pixel", "Görüntünün parlak yerlerinden çevreye ışık yayar (bloom).", ["Işık", "Parlama"], [J("amount", "Yarıçap", 0, 60, 16, 0.5, 0.2), J("thr", "Eşik", 0, 100, 60, 1, 0.5), PCT("str", "Güç", 120, 0, 400), C("tint", "Ton", "#FFFFFF")],
   [P("RY", "Rüya", {"amount": 30, "thr": 40, "str": 160})], pad={"k": "amount", "mul": 2},
   passes=[{"fs": "lightglow_a", "out": "A"}, {"blur": "A", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "lightglow_c", "aux": {"u_aux": "B"}}])
fx("softglow", "Yumuşak Parlama", "Soft Glow", c, "pixel", "Bütün görüntüye rüya gibi yumuşak bir ışıltı verir.", ["Işık", "Parlama", "Rüya"], [J("amount", "Yumuşaklık", 0, 60, 10, 0.5, 0.2), PCT("str", "Güç", 60), PCT("bright", "Aydınlık", 20)],
   passes=[{"blur": "src", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "softglow", "aux": {"u_aux": "B"}}])
# ---------- Bükme ve Bozulma ----------
c = 3
fx("viewer360", "360° Görüntüleyici", "360º Viewer", c, "pixel", "360 derece görüntünün içinden belli bir yöne bakan normal bir kadraj çıkarır.", ["360", "VR"], [A("yaw", "Sağ-sol", 0), A("pitch", "Yukarı-aşağı", 0), A("roll", "Yatma", 0), J("fov", "Görüş açısı", 10, 170, 90, 0.5, 0.2)])
fx("curl", "Kıvır", "Curl", c, "pixel", "Görüntüyü bir kenarından rulo gibi kıvırır.", ["Bükme", "Kâğıt"], [PCT("amount", "Kıvrılma", 40), A("ang", "Yön", 0), J("rad", "Rulo yarıçapı", 2, 500, 30, 0.5, 0.2), T("shade", "Gölge", 1)], pad={"add": 30})
fx("graddisp", "Geçişli Yer Değiştirme", "Gradient Displacement", c, "pixel", "Görüntüyü bir geçişe göre kaydırır; bir taraf hiç kaymaz, öbür taraf çok kayar.", ["Bükme"], [XY("amount", "Kaydırma", 60, 0), A("ang", "Geçiş açısı", 90), CH("curve", "Eğri", ["Doğrusal", "Yumuşak", "Dalga"])], pad={"add": 60})
fx("innerbulge", "İçten Şişir / Sıkıştır", "Inner Pinch/Bulge", c, "pixel", "Şeklin dış hattını bozmadan içini şişirir ya da sıkıştırır.", ["Bükme", "Mercek"], [J("amount", "Miktar", -100, 100, 50, 1, 0.5), XY("center", "Merkez", 0, 0), PCT("rad", "Yarıçap", 60, 0, 300)])
fx("ominoglass", "Omino Cam", "Omino Glass", c, "pixel", "Işığı kırıp renkleri ayrıştıran gelişmiş cam: prizma gibi renk saçakları.", ["Doku", "Renk", "Bükme"], [J("amount", "Kırılma", 0, 60, 10, 0.5, 0.2), J("size", "Desen", 2, 300, 30, 0.5, 0.2), PCT("disp", "Renk ayrışması", 60), CH("tex", "Desen", ["Dalgalı", "Hücreli", "Şeritli", "Damla"]), J("speed", "Hareket", 0, 5, 0.3, 0.01, 0.01)])
fx("polardisp", "Kutupsal Yer Değiştirme", "Polar Displacement Map", c, "pixel", "Görüntüyü merkeze göre içe-dışa ve dönerek, kendi parlaklığıyla kaydırır.", ["Bükme", "Psikedelik"], [J("radial", "İçe-dışa", -200, 200, 30, 0.5, 0.2), A("twist", "Dönme", 20), CH("src", "Kaynak", ["Parlaklık", "Saydamlık", "Gürültü"]), XY("center", "Merkez", 0, 0)], pad={"add": 40})
fx("vrcombined", "360° Birleşik", "VR Combined", c, "pixel", "360 görüntüyü döndürüp, bakış açısını ve renk saçağını tek efektte ayarlar.", ["360", "VR"], [A("yaw", "Sağ-sol", 0), A("pitch", "Yukarı-aşağı", 0), J("fov", "Görüş açısı", 10, 360, 360, 0.5, 0.2), J("chroma", "Renk saçağı", 0, 20, 0, 0.1, 0.05)])
# ---------- Prosedürel ----------
c = 4
fx("contourstrips", "Kontur Şeritleri", "Contour Strips", c, "pixel", "Parlaklığa göre basamaklı şeritler: topografik harita gibi.", ["Desen", "Harita", "Grafik"], [J("levels", "Şerit sayısı", 2, 64, 10, 1, 0.1), C("c1", "Alçak", "#0B1430"), C("c2", "Yüksek", "#22D3C5"), J("lw", "Çizgi", 0, 10, 1, 0.1, 0.05), J("speed", "Akış", -5, 5, 0, 0.01, 0.01), MIX()])
fx("grunge", "Kirli Doku", "Grunge", c, "pixel", "Eskimiş, lekeli, çizikli bir yüzey dokusu ekler.", ["Doku", "Retro"], [PCT("amount", "Miktar", 60), J("scale", "Ölçek", 10, 1000, 120, 1, 0.5), C("col", "Leke rengi", "#2A1E14"), PCT("scratch", "Çizikler", 40), J("seed", "Tohum", 0, 100, 1, 1, 0.2)])
fx("ominodiff", "Omino Difüzyon+", "Omino Diffusion+", c, "pixel", "Kısıtlı palet ve hatalı renk hesabıyla taneli, dijital glitch görünümü.", ["Glitch", "Retro", "Renk"], [J("levels", "Renk sayısı", 2, 16, 4, 1, 0.1), PCT("err", "Hata", 60), CH("pal", "Palet", ["Özgün renkler", "Oyun konsolu", "Gece", "Neon"]), J("speed", "Değişim", 0, 30, 0, 0.5, 0.2)])
fx("volclouds", "Hacimli Bulutlar", "Volumetric Clouds", c, "gen", "Işık alan, derinliği olan 3B bulutlar.", ["Doğa", "Gök", "3B"], [J("scale", "Ölçek", 10, 2000, 200, 1, 0.5), PCT("cover", "Kaplama", 55), J("speed", "Rüzgâr", 0, 5, 0.4, 0.01, 0.01), A("sun", "Güneş açısı", 45), C("sky", "Gök", "#5FB2F2"), C("cloud", "Bulut", "#FFFFFF")] + G())
# ---------- 3B ----------
c = 5
fx("box3d", "Kutu", "Box", c, "3d", "Eni, boyu ve derinliği ayrı ayarlanan kutu.", ["3B", "Şekil"], R3(20, 30, 0, 40) + [PCT("depth", "Derinlik", 50, 1, 300)])
fx("ellipsoid", "Elipsoit", "Ellipsoid", c, "3d", "Basık ya da uzun küre (yumurta, mercimek).", ["3B", "Şekil"], R3(10, 0, 0, 40) + [PCT("sx", "En", 100, 10, 300), PCT("sy", "Boy", 70, 10, 300), PCT("sz", "Derinlik", 100, 10, 300)])
fx("hollowbox", "İçi Boş Kutu", "Hollow Box", c, "3d", "Kapağı açık, içi görünen kutu.", ["3B", "Şekil"], R3(-30, 30, 0, 40) + [PCT("depth", "Derinlik", 80, 1, 300), PCT("wall", "Duvar kalınlığı", 8, 1, 40)])
fx("ring3d", "Halka", "Ring", c, "3d", "Kalın, yassı bir halka (yüzük, disk).", ["3B", "Şekil"], R3(60, 0, 0, 40) + [PCT("hole", "Delik", 50, 0, 95), PCT("thick", "Kalınlık", 20, 1, 100)])
fx("starpoly", "Yıldız Çokyüzlü", "Star Polyhedron", c, "3d", "Her yöne sivri uçlu 3B yıldız (yıldızlı sekizyüzlü).", ["3B", "Şekil", "Yıldız"], R3(20, 20, 0, 50))
fx("cross3", "Üç Eksenli Haç", "Three-axis Cross", c, "3d", "Üç eksende birbirini kesen çubuklardan oluşan 3B haç.", ["3B", "Şekil"], R3(25, 35, 0, 40) + [PCT("thick", "Kalınlık", 30, 5, 100)])
fx("triprism", "Üçgen Prizma", "Triangular Prism", c, "3d", "Üçgen tabanlı prizma.", ["3B", "Şekil"], R3(15, 30, 0, 40))
fx("tunnel", "Tünel", "Tunnel", c, "3d", "Katman bir tünelin duvarlarına sarılır; içinde ilerliyormuş gibi.", ["3B", "Hız", "Psikedelik"], [J("speed", "İlerleme hızı", -10, 10, 1, 0.05, 0.02), J("twist", "Dönme", -360, 360, 30, 1, 0.5), CH("shape", "Kesit", ["Daire", "Kare", "Altıgen", "Üçgen"]), PCT("fog", "Uzaklık sisi", 60), J("rep", "Doku tekrarı", 1, 20, 4, 0.1, 0.05)])
# ---------- Taşı ve Dönüştür ----------
c = 6
fx("growparts", "Parçaları Büyüt", "Grow Parts", c, "pixel", "Katmanı parçalara (harf, karo) ayırıp her parçayı sırayla büyütür.", ["Hareket", "Ölçek", "Giriş"], [CH("by", "Parça", ["Kareler", "Altıgenler", "Yatay şeritler", "Dikey şeritler"]), J("size", "Parça boyu", 4, 500, 40, 0.5, 0.2), PCT("prog", "İlerleme", 100), PCT("stag", "Sıralama", 60), CH("order", "Sıra", ["Soldan", "Merkezden", "Rastgele"])],
   [P("GR", "Parça parça gel", keys={"prog": [[0, 0], [1, 100]]})])
fx("morphpath", "Yol Dönüşümü", "Morph Path", c, "shape", "Uygulamanın şeklini başka bir şekle yumuşakça dönüştürür (daireden yıldıza…).", ["Şekil", "Animasyon"], [CH("to", "Hedef şekil", ["Daire", "Kare", "Üçgen", "Yıldız", "Kalp", "Altıgen", "Artı", "Hilal"], 3), PCT("prog", "İlerleme", 50), T("rot", "Dönerek", 0)], [P("DN", "Dönüş", keys={"prog": [[0, 0], [1, 100]]})], info="Sadece uygulamanın şekillerinde çalışır.")
fx("movepath", "Yol Üzerinde Hareket", "Move Along Path", c, "xform", "Katmanı bir yol boyunca (daire, sekiz, dalga, kalp…) taşır.", ["Hareket", "Yol"], [CH("path", "Yol", ["Daire", "Sekiz", "Dalga", "Kalp", "Yıldız", "Kare", "Zikzak"]), J("size", "Yol boyu", 0, 3000, 200, 1, 0.5), J("speed", "Hız (tur/sn)", -5, 5, 0.3, 0.01, 0.01), T("face", "Yöne bak", 1), PCT("start", "Başlangıç", 0)])
fx("oscillate", "Salınım", "Oscillate", c, "xform", "Katman seçtiğin yönde ileri geri gider gelir.", ["Hareket"], [A("ang", "Yön", 0), J("amount", "Mesafe", 0, 1000, 40, 0.5, 0.2), J("speed", "Hız", 0.05, 10, 1, 0.05, 0.02), CH("wave", "Dalga", ["Yumuşak", "Üçgen", "Kare", "Sıçrama"])])
fx("scaleassist", "Ölçek Yardımcısı", "Scale Assist", c, "xform", "Katmanı istediğin noktadan, piksel bozmadan ölçekler (piksel sanatı için keskin büyütme).", ["Ölçek", "Piksel"], [PCT("scale", "Ölçek", 200, 1, 2000), XY("anchor", "Dayanak noktası", 0, 0), T("crisp", "Keskin pikseller", 1)])
fx("shakeparts", "Parçaları Salla", "Shake Parts", c, "pixel", "Katmanı parçalara ayırıp her parçayı ayrı titretir.", ["Hareket", "Titreşim", "Glitch"], [CH("by", "Parça", ["Kareler", "Yatay şeritler", "Dikey şeritler"]), J("size", "Parça boyu", 4, 500, 30, 0.5, 0.2), J("amount", "Mesafe", 0, 100, 6, 0.1, 0.05), A("rot", "Açı", 8), J("speed", "Hız", 0, 30, 8, 0.1, 0.05)], pad={"k": "amount", "mul": 2})
fx("stretchaxis", "Eksende Esnet", "Stretch Axis", c, "xform", "Katmanı istediğin açıdaki bir eksen boyunca uzatır ya da basar.", ["Ölçek", "Dönüştür"], [A("ang", "Eksen açısı", 0), PCT("amount", "Esnetme", 150, 1, 1000), T("keep", "Alanı koru", 0)])
# ---------- Çizim ve Kenar ----------
c = 1
fx("contourgrad", "Kontur Geçişi", "Contour Gradient", c, "pixel", "Şeklin kenarından içine doğru renk geçişi (kabarık rozet görünümü).", ["Renk", "Kenar", "Geçiş"], [C("c1", "Kenar", "#22D3C5"), C("c2", "İç", "#0B1430"), J("width", "Genişlik", 1, 200, 30, 0.5, 0.2), J("rep", "Tekrar", 1, 20, 1, 1, 0.1), MIX()])
fx("contourlines", "Kontur Çizgileri", "Contour Lines", c, "pixel", "Şeklin kenarına paralel iç içe çizgiler.", ["Kenar", "Çizgi", "Grafik"], [J("space", "Aralık", 1, 100, 8, 0.5, 0.2), J("lw", "Çizgi", 0.5, 20, 2, 0.1, 0.05), J("count", "Çizgi sayısı", 1, 50, 6, 1, 0.1), C("col", "Renk", "#22D3C5"), CH("side", "Yer", ["Dışarı", "İçeri", "İki yana"]), J("speed", "Akış", -50, 50, 0, 0.5, 0.2)], pad={"add": 60})
fx("electricedges", "Elektrikli Kenarlar", "Electric Edges", c, "pixel", "Kenarlarda çakan elektrik akımları.", ["Enerji", "Kenar", "Neon"], [C("col", "Renk", "#9AD8FF"), J("width", "Kalınlık", 0.5, 10, 2, 0.1, 0.05), J("amount", "Dağınıklık", 0, 60, 12, 0.5, 0.2), J("speed", "Hız", 0, 30, 10, 0.1, 0.05), PCT("glow", "Parlama", 150, 0, 400)], pad={"k": "amount", "mul": 1.5, "add": 20})
fx("glowscan", "Parlama Taraması", "Glow Scan", c, "pixel", "Sadece seçtiğin parlaklık aralığındaki yerleri bulanıklaştırıp parlatır; aralık kayarak tarar.", ["Işık", "Parlama", "Tarama"], [PCT("lo", "Aralık alt", 40), PCT("hi", "Aralık üst", 70), J("amount", "Yarıçap", 0, 60, 10, 0.5, 0.2), PCT("str", "Güç", 150, 0, 400), J("speed", "Tarama hızı", -5, 5, 0, 0.01, 0.01)], pad={"k": "amount", "mul": 2},
   passes=[{"fs": "glowscan_a", "out": "A"}, {"blur": "A", "r": {"k": "amount", "mul": 1}, "out": "B"}, {"fs": "glowscan_c", "aux": {"u_aux": "B"}}])
fx("halftonelines", "Yarım Ton Çizgileri", "Halftone Lines", c, "pixel", "Görüntüyü kalınlığı değişen paralel çizgilerle çizer (gravür).", ["Retro", "Baskı", "Grafik"], [J("space", "Aralık", 2, 60, 8, 0.5, 0.2), A("ang", "Açı", 30), J("wave", "Dalgalanma", 0, 30, 0, 0.5, 0.2), C("col", "Mürekkep", "#0B1430"), C("bg", "Kâğıt", "#F7F8FA")])
fx("smoothedges", "Kenar Yumuşatma", "Smooth Edges", c, "pixel", "Tırtıklı, pikselli kenarları pürüzsüzleştirir.", ["Kenar", "Netlik"], [J("amount", "Miktar", 0, 20, 2, 0.1, 0.05), PCT("thr", "Keskinlik", 50)])
fx("stroketaper", "Çizgi İnceltme", "Stroke Taper", c, "shape", "Şeklin çizgisinin uçlarını incelterek el çizimi gibi yapar (Çizerek Belirme ile).", ["Çizgi", "Kenar"], [PCT("start", "Baş incelme", 30), PCT("end", "Son incelme", 30), PCT("wave", "Kalınlık dalgası", 0)], info="Çizerek Belirme ya da Kontur ile birlikte uygulamanın şekillerinde çalışır.")
# ---------- Maske ----------
fx("lumastamp", "Parlaklık Damgası", "Luma Stamper", 8, "pixel", "Katmanın parlaklığını saydamlığa çevirir; açık yerler görünür, koyular kaybolur.", ["Maske", "Anahtar"], [PCT("contrast", "Kontrast", 100, 0, 400), T("inv", "Tersine çevir", 0), T("keepc", "Rengi koru", 1)])
# ---------- Tekrar ----------
c = 7
fx("repeatpath", "Yol Boyunca Tekrar", "Repeat Along Path", c, "repeat", "Kopyaları bir yol (daire, dalga, kalp, yıldız…) boyunca dizer.", ["Tekrar", "Yol"], [CH("path", "Yol", ["Daire", "Dalga", "Kalp", "Yıldız", "Spiral", "Sekiz"]), J("count", "Kopya", 1, 60, 12, 1, 0.1), J("size", "Yol boyu", 10, 3000, 200, 1, 0.5), T("face", "Yöne dön", 1), J("speed", "Akış", -5, 5, 0.1, 0.01, 0.01), PCT("scl", "Kopya ölçeği", 40, 1, 200)], pad={"add": 0})
fx("scatterfield", "Saçılım Alanı", "Scatter Field", c, "repeat", "Bütün kareyi katmanın kopyalarıyla rastgele ve sık doldurur; kopyalar süzülür.", ["Tekrar", "Parçacık", "Desen"], [PCT("density", "Yoğunluk", 50), PCT("scl", "Kopya ölçeği", 25, 1, 200), PCT("svar", "Ölçek farkı", 50), J("speed", "Süzülme", 0, 5, 0.3, 0.01, 0.01), A("dir", "Yön", 90), J("seed", "Tohum", 0, 100, 1, 1, 0.2)], pad={"add": 0})
# ---------- Diğer ----------
c = 11
fx("remaphsv", "Kanal Yeniden Eşleme (HSV)", "Channel Remap (HSV)", c, "pixel", "Ton, doygunluk ve parlaklık kanallarını birbirinin yerine koyar ya da sabitler.", ["Kanal", "Renk"],
   [CH("h", "Ton ←", ["Ton", "Doygunluk", "Parlaklık", "Sabit"], 0), CH("s", "Doygunluk ←", ["Ton", "Doygunluk", "Parlaklık", "Sabit"], 1), CH("v", "Parlaklık ←", ["Ton", "Doygunluk", "Parlaklık", "Sabit"], 2), PCT("const", "Sabit değer", 50)])
fx("magnifybg", "Arka Planı Büyüt", "Magnify Background", c, "pixel", "Katmanın şeklinde, arkasındaki görüntüyü büyüterek gösterir (büyüteç).", ["Arka plan", "Mercek"], [PCT("zoom", "Büyütme", 200, 100, 1000), J("ring", "Çerçeve", 0, 20, 3, 0.1, 0.05), C("ringc", "Çerçeve rengi", "#F7F8FA")], info="Katmanı bir daire şekli yapıp üstüne ekle: büyüteç olur.")

# ---------- Birleştirmeler: bu 20 efekt tarayıcıda ayrı görünmez; birleştiği efektin içinde seçenek / hazır ayardır ----------
MERGE = {
  "brightness": ("bricon", "Parlaklık"), "contrast": ("bricon", "Kontrast"), "saturate": ("vibrance", "Doygunluk"),
  "duotone": ("gradmap", "İki ton"), "spectral": ("colorama", "Spektrum"), "changecolor": ("replacecolor", "Rengi ayarla"),
  "gradientfill": ("gradoverlay", "Geçiş dolgusu"), "colorkey": ("lincolorkey", "Renk anahtarı"), "extract": ("lumakey", "Ayıkla"),
  "spherize": ("bulge", "Küreleştir"), "fisheye": ("opticscomp", "Balık gözü"), "heatwave": ("displace", "Isı dalgası"),
  "motiontile": ("repetile", "Hareketli döşeme"), "lightburst": ("lightrays", "Işık patlaması"), "turbulence": ("fractalnoise", "Türbülans"),
  "voronoi": ("cellpattern", "Hücreler"), "starburst": ("starfield", "Yıldız patlaması"), "grain": ("noise", "Film greni"),
  "strobe": ("blink", "Flaş"), "widetime": ("echo", "Geniş zaman"),
}
byType = {e["type"]: e for e in E}
for old, (into, label) in MERGE.items():
    o = byType[old]; o["hidden"] = True; o["mergedInto"] = into
    tgt = byType[into]; tgt.setdefault("aliases", []).append({"type": old, "name": o["name"], "en": o["en"]})
    # Birleşenin adı hedefin hazır ayarı olur (aramada bulunur, dokununca birleşen efektin varsayılanlarıyla eklenir)
    tgt["presets"].append(dict(code=old[:2].upper(), name=label, vals={}, keys={}, cols={}, at="start", alias=old))
