# Telefonda yapılabildiğini bulduğumuz ek efektler (After Effects'te "telefonda zor" görünenler)
c = 0
fx("hdrsdr", "HDR'den SDR'ye", "HDR to SDR Tone Map", c, "pixel", "Yeni telefonların HDR videolarını normal ekranlarda soluk değil doğal göstermek için ton eşler.", ["Renk", "Video", "HDR"],
   [CH("src", "Kaynak", ["HLG", "PQ (HDR10)", "Otomatik"], 2), J("peak", "Tepe parlaklık (nit)", 100, 4000, 1000, 10, 5), PCT("sat", "Doygunluk", 100, 0, 200), J("exp", "Pozlama", -3, 3, 0, 0.01, 0.01)])
fx("logconv", "Log'dan Normale", "Log to Rec.709", c, "pixel", "Log ile çekilmiş soluk videoları normal renge çevirir.", ["Renk", "Video", "Sinema"],
   [CH("log", "Log türü", ["Samsung Log", "Apple Log", "Sony S-Log3", "Canon C-Log", "Cineon (film)"]), PCT("amount", "Güç", 100), J("exp", "Pozlama", -3, 3, 0, 0.01, 0.01)])
fx("colorprofile", "Renk Profili", "Color Profile Converter", c, "pixel", "Renk uzayları arasında dönüşüm (Display P3, sRGB, Rec.2020).", ["Renk", "Teknik"],
   [CH("from", "Kaynak", ["sRGB / Rec.709", "Display P3", "Rec.2020", "Doğrusal"]), CH("to", "Hedef", ["sRGB / Rec.709", "Display P3", "Rec.2020", "Doğrusal"], 1)])
fx("broadcast", "Yayın Renkleri", "Broadcast Colors", c, "pixel", "Renkleri ve parlaklığı televizyon yayın sınırları içine çeker.", ["Renk", "Video", "Teknik"], [PCT("max", "En yüksek (IRE)", 100, 80, 120), CH("how", "Nasıl", ["Doygunluğu azalt", "Parlaklığı azalt"])])
fx("colorstab", "Renk Sabitleme", "Color Stabilizer", c, "pixel", "Timelapse ve videolarda kareden kareye değişen ışığı ve rengi dengeler.", ["Renk", "Video", "Timelapse"], [PCT("amount", "Güç", 80), J("target", "Hedef parlaklık", 0, 100, 50, 1, 0.5), T("color", "Rengi de dengele", 1)])
c = 2
fx("deblur", "Bulanıklık Giderme", "Shake Deblur", c, "pixel", "Belli yöndeki hareket bulanıklığını kısmen geri alır.", ["Netlik", "Fotoğraf", "Video"], [J("len", "Bulanıklık uzunluğu", 0, 60, 8, 0.5, 0.2), A("ang", "Açı", 0), PCT("amount", "Güç", 70), J("iter", "Yineleme", 1, 8, 3, 1, 0.1)])
fx("upscale", "Ayrıntılı Büyütme", "Detail-preserving Upscale", c, "pixel", "Küçük görseli büyütürken kenarları keskin ve ayrıntıyı korur.", ["Netlik", "Büyütme"], [PCT("scale", "Ölçek", 200, 100, 400), PCT("detail", "Ayrıntı", 50), PCT("noise", "Gürültü azalt", 20)], pad={"add": 0})
c = 3
fx("liquify", "Sıvılaştır", "Liquify", c, "pixel", "Parmakla it, çek, döndür, şişir ya da sıkıştır (önizlemede noktaları sürükle).", ["Bükme", "Fırça"],
   [CH("tool", "Araç", ["İt", "Saat yönü döndür", "Ters döndür", "Şişir", "Sıkıştır"]), XY("from", "Fırça yeri", 0, 0), XY("to", "İtme yönü", 40, 0), J("rad", "Fırça boyu", 5, 1000, 80, 1, 0.5), PCT("str", "Güç", 70)])
c = 4
fx("paintbucket", "Boya Kovası", "Paint Bucket", c, "pixel", "Dokunduğun noktadaki aynı renkli alanı seçtiğin renkle doldurur.", ["Renk", "Doldur"], [XY("pos", "Nokta", 0, 0), C("col", "Renk", "#22D3C5"), PCT("tol", "Tolerans", 15), J("feather", "Yumuşaklık", 0, 20, 1, 0.1, 0.05), CH("mode", "Tür", ["Doldur", "Sadece kenar", "Saydam yap"])], heavy=True)
fx("eyedropper", "Damlalık Dolgu", "Eyedropper Fill", c, "pixel", "Seçtiğin noktadaki rengi alıp bütün katmanı o renge boyar.", ["Renk", "Doldur"], [XY("pos", "Nokta", 0, 0), J("rad", "Örnek alanı", 0, 50, 2, 0.5, 0.2), PCT("mix", "Karışım", 100), T("keep", "Işığı koru", 0)])
c = 8
fx("diffmatte", "Fark Matı", "Difference Matte", c, "special", "Videonun boş (temiz arka planlı) bir karesine göre değişmeyen yerleri saydam yapar.", ["Maske", "Anahtar", "Video"], [J("ref", "Temiz kare (sn)", 0, 1e5, 0, 0.04, 0.02), PCT("tol", "Tolerans", 12), PCT("soft", "Yumuşaklık", 10)], info="Arka planın boş olduğu anı 'Temiz kare' olarak seç.")
fx("wireremove", "Tel Silme", "Wire Removal", c, "pixel", "İki nokta arasındaki ince çizgiyi (tel, ip) çevresiyle doldurarak siler.", ["Temizlik", "Video"], [XY("a", "Uç 1", -100, -60), XY("b", "Uç 2", 100, 60), J("width", "Kalınlık", 0.5, 40, 4, 0.1, 0.05), J("soft", "Yumuşaklık", 0, 20, 2, 0.1, 0.05)])
fx("fringe", "Renk Saçağı Temizle", "Remove Color Matting", c, "pixel", "Kesilmiş nesnenin kenarında kalan eski arka plan rengini temizler.", ["Maske", "Kenar"], [C("bg", "Eski arka plan", "#22B14C"), PCT("amount", "Güç", 100)])
c = 11
fx("matchgrain", "Gren Eşle", "Match Grain", c, "special", "Katmanın kendi grenini ölçer, efektlerden (bulanıklık gibi) sonra kaybolan greni geri ekler.", ["Gürültü", "Video", "Film"], [PCT("amount", "Güç", 100, 0, 300), J("size", "Tane", 0.5, 5, 1, 0.05, 0.02)], info="Efekt listesinde sona koy.")
fx("timediff", "Zaman Farkı", "Time Difference", TIM, "special", "Şimdiki kare ile biraz önceki kare arasında değişen yerleri gösterir (hareket algılama görünümü).", ["Zaman", "Hareket", "Bilim"], [J("off", "Fark (sn)", 0.01, 2, 0.1, 0.005, 0.002), PCT("gain", "Kazanç", 300, 0, 1000), T("abs", "Mutlak fark", 1), T("color", "Renkli", 1)])
fx("chrome", "Krom Yansıma", "Environment (Chrome)", 1, "pixel", "Katmanı parlak krom gibi yapar; kendi görüntüsünü yansıtır.", ["Metal", "Işık", "3B"], [J("bump", "Kabartı", 0, 30, 6, 0.1, 0.05), PCT("refl", "Yansıma", 80), C("tint", "Ton", "#DCE6F5"), J("spin", "Ortam dönmesi", -360, 360, 20, 1, 0.5)])
# Portre fotoğraflarındaki gömülü derinlik haritası (Google/Samsung portre modu) — yapay zeka yok
DI = "Telefonun portre modunda çekilmiş, içinde derinlik haritası olan fotoğraflarda çalışır."
fx("depthblur", "Arka Plan Bulanıklığı (Derinlik)", "Depth of Field", 2, "pixel", "Portre fotoğrafının derinlik haritasıyla odak dışını bulanıklaştırır; odağı sonradan değiştirebilirsin.", ["Bulanık", "Fotoğraf", "Portre"], [J("focus", "Odak uzaklığı", 0, 100, 20, 0.5, 0.2), J("amount", "Bulanıklık", 0, 60, 16, 0.5, 0.2), PCT("range", "Net alan", 15)], info=DI, heavy=True)
fx("depthmatte", "Derinlik Matı", "Depth Matte", 8, "pixel", "Belli bir uzaklıktan ötesini saydam yapar (arka planı silme).", ["Maske", "Portre"], [J("depth", "Uzaklık", 0, 100, 40, 0.5, 0.2), PCT("soft", "Yumuşaklık", 10), T("inv", "Önü sil", 0)], info=DI)
fx("depthfog", "3B Sis", "Fog 3D", 11, "pixel", "Uzaktaki yerleri derinliğe göre sisle örter.", ["Atmosfer", "Portre", "3B"], [J("start", "Sis başlangıcı", 0, 100, 30, 0.5, 0.2), J("end", "Tam sis", 0, 100, 100, 0.5, 0.2), C("col", "Renk", "#DCE6F5"), PCT("dens", "Yoğunluk", 80)], info=DI)
