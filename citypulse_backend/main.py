from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine
from app import models
from app.routers import cities, stats, feedback

# NOT: Veritabanı zaten mevcut - sadece bağlanıyoruz, tablo oluşturmuyoruz
# models.Base.metadata.create_all(bind=engine)  # KAPALI - Veritabanı hazır

# FastAPI uygulamasını oluştur
app = FastAPI(
    title="Turkcell Code Night - Yolcu Projesi API",
    description="Mevcut veritabanından veri çeker ve Flutter'a sunar - READ-ONLY modda çalışır",
    version="2.0.0"
)

# CORS ayarları - Flutter mobil uygulamanın API'ye erişebilmesi için
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Geliştirme için tüm origin'lere izin ver
    allow_credentials=True,
    allow_methods=["*"],  # Tüm HTTP metodlarına izin ver (GET, POST, PUT, DELETE)
    allow_headers=["*"],  # Tüm header'lara izin ver
)

# Router'ları ekle (Sadece READ endpoint'leri aktif)
app.include_router(cities.router)
app.include_router(stats.router)
app.include_router(feedback.router)
app.include_router(feedback.categories_router)

# Yeni eklenen router'lar
from app.routers import weather, paycell, scores, city_statistics, location
app.include_router(weather.router)
app.include_router(paycell.router)
app.include_router(scores.router)
app.include_router(city_statistics.router)
app.include_router(location.router)


@app.get("/")
def read_root():
    """Ana sayfa endpoint'i"""
    return {
        "message": "Turkcell Proje API'ye hoş geldiniz!",
        "docs": "/docs",
        "redoc": "/redoc"
    }


@app.get("/health")
def health_check():
    """Sağlık kontrolü endpoint'i"""
    return {"status": "healthy"}


# Uygulamayı çalıştırmak için:
# uvicorn main:app --reload
