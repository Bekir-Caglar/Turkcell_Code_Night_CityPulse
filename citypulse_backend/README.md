# Turkcell Code Night - Yolcu Projesi Backend API

## 🎯 Proje Özeti

Backend **READ-ONLY** modda çalışır. Mevcut SQLite veritabanından veri çeker ve Flutter uygulamasına sunar.

## ⚠️ ÖNEMLİ NOTLAR

- ✅ **Veritabanı hazır** - Backend sadece verileri okur
- ✅ **CRUD işlemlerinden sadece READ (GET) aktif**
- ❌ CREATE/UPDATE/DELETE endpoint'leri kapalı
- ✅ Flutter için optimize edilmiş response formatı
- ✅ CORS aktif - tüm origin'lere izin var

## 🚀 Hızlı Başlangıç

### 1. Uygulamayı Çalıştır
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2. API Dokümantasyonu
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc
- **Health Check:** http://localhost:8000/health

## 📡 API Endpoints (Sadece GET)

### Şehirler (`/api/cities/`)
- `GET /api/cities/` - Tüm şehirler
- `GET /api/cities/{city_id}` - Tek şehir

### Ağ İstatistikleri (`/api/stats/`)
- `GET /api/stats/` - Tümü
- `GET /api/stats/{city_id}` - Şehre göre
- `GET /api/stats/{city_id}/{date}` - Şehir + tarih

### Hava Durumu (`/api/weather/`)
- `GET /api/weather/` - Tümü
- `GET /api/weather/{city_id}` - Şehre göre
- `GET /api/weather/{city_id}/{date}` - Şehir + tarih

### Paycell (`/api/paycell/`)
- `GET /api/paycell/` - Tümü
- `GET /api/paycell/{city_id}` - Şehre göre
- `GET /api/paycell/{city_id}/{date}` - Şehir + tarih

### Skorlar (`/api/scores/`)
- `GET /api/scores/` - Tümü
- `GET /api/scores/{city_id}` - Şehre göre
- `GET /api/scores/{city_id}/{date}` - Şehir + tarih

### Feedback (`/api/feedback/`)
- `GET /api/feedback/` - Tümü
- `GET /api/feedback/{id}` - Tek feedback
- `GET /api/feedback/city/{city_id}` - Şehre göre

### Kategoriler (`/api/categories/`)
- `GET /api/categories/` - Tümü
- `GET /api/categories/{name}` - Tek kategori

### 3. Flutter İçin Response Formatı

Tüm endpoint'ler standart bir format döner:

**Başarılı Response:**
```json
{
  "success": true,
  "message": "İşlem başarılı",
  "data": { ... }
}
```

**Hata Response:**
```json
{
  "success": false,
  "message": "Hata mesajı",
  "data": null,
  "error_code": "ERROR_CODE"
}
```

### 4. Flutter İçin Örnek Request'ler

#### Tüm Şehirleri Getir
```
GET http://localhost:8000/api/cities/
```

#### Ankara'nın Verilerini Getir
```
GET http://localhost:8000/api/cities/06
```

#### Ankara'nın Ağ Verilerini Getir
```
GET http://localhost:8000/api/stats/06
```

#### Belirli Tarihte Hava Durumu
```
GET http://localhost:8000/api/weather/34/2024-11-20
```

### 5. Flutter İçin Önemli Notlar

- ✅ CORS aktif - Flutter'dan direkt istek atabilirsin
- ✅ Tüm response'lar standart formatta
- ✅ Error handling düzgün yapılmış
- ✅ SQLite kullanıldığı için kolay deployment

### 6. Geliştirme İpuçları

**Hızlı test için:**
```bash
# API'yi test et
curl http://localhost:8000/health

# Item oluştur
curl -X POST http://localhost:8000/api/items/ \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","description":"Test item","price":50.0,"is_available":true}'

# Tüm itemları getir
curl http://localhost:8000/api/items/
```

**Flutter'da Kullanım:**
```dart
// Dart/Flutter örnek
final response = await http.get(
  Uri.parse('http://YOUR_IP:8000/api/items/')
);

if (response.statusCode == 200) {
  final Map<String, dynamic> data = json.decode(response.body);
  if (data['success']) {
    final items = data['data'];
    // items listesini kullan
  }
}
```

### 7. Veritabanı

- SQLite kullanılıyor (`sql_app.db`)
- İlk çalıştırmada otomatik oluşturulur
- Tablolar otomatik migrate edilir

### 8. Proje Yapısı

```
├── main.py                   # Ana uygulama dosyası
├── sql_app.db               # SQLite veritabanı
└── app/
    ├── database.py          # DB bağlantısı
    ├── models.py            # SQLAlchemy modelleri
    ├── schemas.py           # Pydantic şemaları
    ├── utils.py             # Yardımcı fonksiyonlar
    └── routers/
        └── items.py         # CRUD endpoints
```

### 9. Production İçin (İleride)

```bash
# Gunicorn ile production
pip install gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker
```

### 10. Troubleshooting

**Flutter'dan bağlanamıyorum:**
- Backend'i `--host 0.0.0.0` ile çalıştırdığından emin ol
- Flutter'da `localhost` yerine bilgisayarın IP adresini kullan
- Emülatörde: `10.0.2.2:8000` kullan (Android)

**CORS hatası:**
- CORS zaten aktif, sorun olmamalı
- Gerekirse `main.py`'deki `allow_origins` ayarını kontrol et
