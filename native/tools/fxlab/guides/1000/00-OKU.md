# Warden Motion 1000 — son 198 efekt adayı ve güncellemeler

## Sayım ve durum
- Önceki geliştirme hedefi: 800.
- 801 Savrulan Glitch ve 802 Yönlü Yırtılma: iki yeni özgün efekt.
- Toz Dağılması ayrı 803 değildir. 361 Toz Olup Savrul güncellenir; Külleşme, Direnme, Toparlanma, Döngü ve görsel alfa kontrolü aynı efekt içinde kalır.
- 803–1000: 198 yeni tasarım adayı, 9 kategori × 22. Toplam hedef = 800 + 2 + 198 = 1000.
- Araştırma dizini: 70 erişilebilen kaynak sitesi / dokümantasyon girişi. Bir kısmı teknik belge veya filtre listesi, bir kısmı genel ürün/kütüphane taramasıdır. 70 sitenin her alt sayfası veya her eklentisi incelendi anlamına gelmez. Her adayın bölümünde dayanak ailesi belirtilir. Kaynaklardaki hazır efektlerin birebir kopyası değil, tekniklerden türetilmiş özgün tasarım adaylarıdır.
- Toplam 851 yeni özel kontrol satırı. Ayrıca 801, 802, 361, 203 ve mevcut efekt güncellemeleri ayrı dosyada yer alır.
- Önceki 430 rehberi, 431–462 planı, 463–550 rehberi ve 551–800 aday kataloğuna göre ad ve işlev karşılaştırması yapıldı. Tam eşleşen ad yok; ancak aynı motor/işlevin farklı parametreleri olabilecek teknik yakınlıklar hâlâ olabilir. Önceki paketin 27 birleştirme adayı da çözülmeden duruyor. Bu nedenle 1000, kesinlikle farklı ve çalışır efekt sayısı değil, nominal tasarım hedefidir. Birleştirme gerçekleşirse boşalan sayıya gerçekten farklı aday eklenmelidir.
- Kaynak kodu ve cihaz benchmark'ı incelenmedi. Dosya kod değil; geliştirme şartnamesi ve seçim kataloğudur. Verilen aralıklar test/optimizasyon gerektirir. 3B modelleme, harita verisi, ses analizi ve tanılama görselleri de katalogda var; saf 2B görsel filtre sayısına bunların tamamı eklenmemelidir. 

## Öncelikli geliştirme
İlk olarak günlük animasyonda faydalı ve nispeten düşük bağımlılıklı efektleri uygula: iç boşluk tamamlama, ince çizgi tamamlama, renk paleti çıkarımı, kenar yönünde renk uzatma, çizgi ağırlığı, karton kesiti, kâğıt lifleri, çok hedefli ağırlık merkezi, eksen bazında ebeveynlik, iki noktalı esnetme, adım döngüsü, iris kilidi, etiket çakışma önleme, harf iskeleti, katmanların sahne derinliğine göre sıralanması, tempo analizi, ters yankı, nesne arkasından geçiş, döşeme ek yeri onarımı, kadraj güvenli alanı. Gerçek 3B, otomatik analiz ve ses ayrıştırma ayrı motorlar gerektirir; bunları daha sonra test ederek ekle. Öncelik sırası öneridir.

## Ortak geliştirme kuralları
1. Kaynak medya tahribatsız; RGBA doğru premultiplied/straight alfa işleme; gerçek alfa ile renk örtüsünü karıştırma.
2. Arayüzde Türkçe açıklama, değer birimi ve sıfırlama; kontrol tipleri, aralıklar ve varsayılanlar bölüm tablolarında. Zamanla değişebilir sayısal değerler anahtar kareli; enum/anahtar adımlı; kaynak/analiz seçimleri sabit. Eksik katman, rig, model veya dosya olduğunda sessiz yanlış sonuç yerine açıklayıcı uyarı ve etkisiz çıktı.
3. Rastgele animasyonlar sabit tohum + zaman + parça kimliği ile deterministik; geri sarma ve dışa aktarma aynı zaman noktasında eş sonuç. Kaynak değişikliklerinde önbellek geçersizleşir. Döngü ve anahtar kareler ileri-geri test edilir.
4. Lite yalnız önizleme örneklemesini, geçici render çözünürlüğünü, parçacık ve örnek bütçesini düşürür. Dışa aktarımda tam kullanıcı değerleri korunur. Düşük RAM'de arabellek boyutunu sınırlayıp ara çıktıları temizle; kareler arası filtrelerde gerekli zaman penceresini yönet.
5. 3B efektlerde mesh/UV/normal/derinlik gereksinimini açık göster. Veri görselleştirmelerinde kullanıcıdan sağlanan CSV/JSON/GeoJSON/DEM doğrulanmalı; kaynak ve tarih belirtilmeli. Sonuç tahminiyse açıkça işaretle. Yerel/izinli ses modeli kullan; ayrıştırma kusursuz değildir. Kaynak lisansına uy, lisanssız eklenti kodu veya materyal kopyalama.
6. WardenCB Öğret: her efekt için gereken medya ve katmanları içeren küçük örnek proje, önce varsayılan sonra iki zıt ayar denemesi, önce/sonra karşılaştırması. Kullanıcı değerlerini değiştirebilsin; öğretim projesi ana projeyi bozmasın.
7. Varsayılan, min, max; şeffaf PNG; hareketli kaynak; farklı çözünürlük ve FPS; anahtar kare; ileri/geri sarma; Lite/tam kalite; dışa aktarma testleri. Yüksek frekanslı ışık efektlerinde düşük kontrastlı güvenli varsayılan ve ışık hassasiyeti uyarısı.
8. Mevcut efektlerle aynı sonucu veren önerilerde ayrı ID yerine yeni mod veya hazır şablon. Eski kayıtları kırma; 361 ve 203 gibi güncellemelerde sürüm uyumluluğu şart. 

## ZIP içeriği
- 9 bölüm (her biri 22 efekt): 803–1000.
- 00-OKU.md, 00-Efekt-Indeksi.md, 00-Kaynaklar.md.
- Mevcut-Efekt-Guncellemeleri-801-802.md: 361, külleşme, 801, 802, 203 ve diğer güncellemeler.
- Tam-Katalog.md: bölüm dosyalarının birleşik sürümü. Telefonda küçük kategori dosyalarını açmak daha kolay olabilir.
