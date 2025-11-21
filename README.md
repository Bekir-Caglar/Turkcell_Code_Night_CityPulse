# CityPulse

CityPulse, Türkiye'nin şehirlerindeki çevresel ve teknolojik verileri izleyen, vatandaşların geri bildirimlerini toplayan ve şehir yönetimini destekleyen modern bir mobil uygulamadır.

## Özellikler

### Ana Özellikler
- **Şehir Seçimi ve Harita Entegrasyonu**: Kullanıcılar şehir seçebiliyor ve harita üzerinde şehir merkezine odaklanabiliyor.
- **Gerçek Zamanlı Şehir Verileri**: İnternet trafiği, sinyal gücü, hava kalitesi ve günlük işlemler gibi şehir istatistiklerini görüntülüyor.
- **Uyarı Sistemi**: Şehir verilerine göre otomatik uyarılar (bağlantı sorunları, yoğunluk, hava kalitesi önerileri).
- **Geri Bildirim Sistemi**: Vatandaşlar trafik, çevre, bağlantı ve öneri kategorilerinde geri bildirim gönderebiliyor.
- **Yeşil Şehirler Sıralaması**: Haftanın en sürdürülebilir şehirlerini gösteriyor.
- **Çoklu Ekran Desteği**: Ana sayfa, uyarılar, geri bildirimler ve veri girişi ekranları.

### Teknik Özellikler
- **Flutter Framework**: Cross-platform mobil uygulama geliştirme.
- **Dio HTTP Client**: Güvenli ve hızlı API iletişimi.
- **OpenStreetMap Entegrasyonu**: Harita gösterimi için FlutterMap kullanımı.
- **Konum Servisleri**: GPS tabanlı şehir algılama.
- **State Management**: Singleton pattern ile şehir durumu yönetimi.
- **Responsive Design**: Farklı ekran boyutlarına uyumlu tasarım.

## Kurulum

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

### Gereksinimler
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio veya VS Code
- Git


### Adımlar
1. **Depoyu Klonlayın**:
   ```bash
   git clone https://github.com/Bekir-Caglar/Code_Night_Yolcu.git
   cd Code_Night_Yolcu/CityPulse
   ```

2. **Bağımlılıkları Yükleyin**:
   ```bash
   flutter pub get
   ```

3. **Uygulamayı Çalıştırın**:
   ```bash
   flutter run
   ```

## Kullanım

### Ana Sayfa
- Şehir seçimi için topbar'daki butona tıklayın.
- Harita üzerinde şehir merkezi gösterilir.
- Şehir skorları (trafik, sinyal, hava kalitesi, işlemler) kartlarda görüntülenir.
- Yeşil şehirler sıralaması ve bilgi kartları en altta yer alır.

### Uyarılar Sayfası
- Şehir verilerine göre otomatik uyarılar.
- Bar grafikleri ile görsel veri gösterimi.
- Uyarı kartları ile öneriler.

### Geri Bildirim
- Vatandaş geri bildirim formu.
- Kategorilere göre sınıflandırma (Trafik, Çevre, Bağlantı, Öneri).

## API Dokümantasyonu

### Ana Endpoints
- `GET /api/cities` - Şehir listesi
- `GET /api/city-statistics/{city_id}/summary` - Şehir istatistikleri
- `GET /api/scores/{city_id}` - Şehir skorları
- `GET /api/feedback` - Geri bildirim listesi
- `POST /api/feedback/submit` - Geri bildirim gönderme
- `GET /api/location/find-city` - Koordinatlara göre şehir bulma

### Veri Formatları
- Şehir ID'leri: İki haneli string (örn: "06" Ankara için)
- Koordinatlar: Latitude/Longitude
- Skorlar: Eco score ve alerts count

## Proje Yapısı

```
CityPulse/
├── lib/
│   ├── core/
│   │   ├── constants/          # API sabitleri
│   │   ├── models/             # Veri modelleri
│   │   ├── network/            # API servisleri
│   │   ├── state/              # State management
│   │   └── theme/              # Tema ve renkler
│   ├── features/
│   │   ├── home/               # Ana sayfa
│   │   ├── notifications/      # Uyarılar
│   │   ├── feedback/           # Geri bildirim
│   │   └── add_data/           # Veri girişi
│   └── widgets/                # Yeniden kullanılabilir widget'lar
├── android/                    # Android yapılandırması
├── ios/                        # iOS yapılandırması
└── pubspec.yaml                # Flutter bağımlılıkları
```

## Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'i push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

### Geliştirme Standartları
- **Kod Stili**: Flutter/Dart analiz kurallarına uyun
- **Commit Mesajları**: Açık ve açıklayıcı
- **Test**: Yeni özellikler için test ekleyin
- **Dokümantasyon**: Kod değişikliklerini README'de güncelleyin

## Sorun Giderme

### Yaygın Sorunlar
- **API Bağlantı Hatası**: Backend sunucusunun çalıştığından emin olun
- **Konum İzni**: Uygulamaya konum izni verin
- **Harita Gösterimi**: İnternet bağlantısı kontrol edin

### Log'lar
Uygulama log'larını görmek için:
```bash
flutter logs
```

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

*CityPulse - Şehirlerin Nabzını Tutan Uygulama*
