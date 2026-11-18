# Warden Motion

Hareketli grafik, animasyon ve countryball (CB) yapmak için mobil + PC editörü.

**v0.1 · Deneme sürümü**

## Neler var
- Ana sayfa: şablonlar, son projeler, yeni proje (en-boy oranı, çözünürlük, kare hızı, arka fon)
- Editör: önizleme, sürükleyerek taşıma, oynatma, kaydırmalı zaman çizelgesi, kırp/böl, geri al/yinele
- Keyframe animasyonu: konum, döndürme, ölçek, opaklık (yumuşak geçişli)
- Katmanlar: şekil, metin, galeriden görsel
- CB Araçları: Hazır Pack (gövdeler, gözler, ağızlar, şapkalar, aksesuarlar, eşyalar) + Yüklediğim Pack (galeriden PNG, klasörler)
- Bayraklar: tüm ülke bayrakları + kendi bayrağını ekleme; "CB olarak ekle" tek dokunuşla gövde kurar
- Takip Et (çocuk katman) ve Kırpma Maskesi
- Efektler: Gauss Bulanıklığı, Oto-Sallanma, Rastgele Titreşim, Parlama
- 8 öğretici (v0.1'de Temel CB ve Temel Animasyon hazır)
- Video dışa aktarma (MP4 / WebM)

## Geliştirme
```bash
npm install
npm run dev        # tarayıcıda çalıştır
npm run build      # web sürümünü derle (dist/)
npm run pack       # hazır pack PNG'lerini ve bayrak listesini yeniden üret (Playwright gerekir)
npm run android    # derle + Android projesine aktar
cd android && ./gradlew assembleDebug   # APK: android/app/build/outputs/apk/debug/
```

Bayraklar: [flag-icons](https://github.com/lipis/flag-icons) (MIT).
