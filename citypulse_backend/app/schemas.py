from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime


# ==================== CITY SCHEMAS ====================
class CityBase(BaseModel):
    """Şehir için temel şema"""
    city_id: str = Field(..., description="Plaka kodu veya ID")
    name: str = Field(..., description="Şehir adı")
    region: Optional[str] = Field(None, description="Bölge")
    population: Optional[int] = Field(None, ge=0, description="Nüfus")


class CityCreate(CityBase):
    """Yeni şehir oluştururken kullanılan şema"""
    pass


class CityUpdate(BaseModel):
    """Şehir güncellerken kullanılan şema"""
    name: Optional[str] = None
    region: Optional[str] = None
    population: Optional[int] = Field(None, ge=0)


class CityResponse(CityBase):
    """API'den dönen şehir response şeması"""
    
    class Config:
        from_attributes = True


# ==================== CITY STATS SCHEMAS ====================
class CityStatsBase(BaseModel):
    """Ağ verileri için temel şema"""
    city_id: str
    date: date
    signal_strength: Optional[int] = Field(None, description="Sinyal gücü")
    traffic_gb: Optional[int] = Field(None, ge=0, description="Trafik (GB)")


class CityStatsCreate(CityStatsBase):
    """Yeni ağ verisi oluştururken kullanılan şema"""
    pass


class CityStatsUpdate(BaseModel):
    """Ağ verisi güncellerken kullanılan şema"""
    signal_strength: Optional[int] = None
    traffic_gb: Optional[int] = Field(None, ge=0)


class CityStatsResponse(CityStatsBase):
    """API'den dönen ağ verisi response şeması"""
    
    class Config:
        from_attributes = True


# ==================== CITY WEATHER SCHEMAS ====================
class CityWeatherBase(BaseModel):
    """Hava durumu için temel şema"""
    city_id: str
    date: date
    temp_c: Optional[float] = Field(None, description="Sıcaklık (°C)")
    air_quality: Optional[int] = Field(None, ge=0, description="Hava kalitesi")


class CityWeatherCreate(CityWeatherBase):
    """Yeni hava durumu oluştururken kullanılan şema"""
    pass


class CityWeatherUpdate(BaseModel):
    """Hava durumu güncellerken kullanılan şema"""
    temp_c: Optional[float] = None
    air_quality: Optional[int] = Field(None, ge=0)


class CityWeatherResponse(CityWeatherBase):
    """API'den dönen hava durumu response şeması"""
    
    class Config:
        from_attributes = True


# ==================== PAYCELL STATS SCHEMAS ====================
class PaycellStatsBase(BaseModel):
    """Finansal veri için temel şema"""
    city_id: str
    date: date
    transactions_count: Optional[int] = Field(None, ge=0, description="İşlem sayısı")
    total_amount: Optional[float] = Field(None, ge=0, description="Toplam tutar")


class PaycellStatsCreate(PaycellStatsBase):
    """Yeni finansal veri oluştururken kullanılan şema"""
    pass


class PaycellStatsUpdate(BaseModel):
    """Finansal veri güncellerken kullanılan şema"""
    transactions_count: Optional[int] = Field(None, ge=0)
    total_amount: Optional[float] = Field(None, ge=0)


class PaycellStatsResponse(PaycellStatsBase):
    """API'den dönen finansal veri response şeması"""
    
    class Config:
        from_attributes = True


# ==================== CITY SCORES SCHEMAS ====================
class CityScoreBase(BaseModel):
    """Hesaplanan skorlar için temel şema"""
    city_id: str
    date: date
    eco_score: Optional[float] = Field(None, description="Ekonomik skor")
    alerts_count: Optional[int] = Field(None, ge=0, description="Uyarı sayısı")


class CityScoreCreate(CityScoreBase):
    """Yeni skor oluştururken kullanılan şema"""
    pass


class CityScoreUpdate(BaseModel):
    """Skor güncellerken kullanılan şema"""
    eco_score: Optional[float] = None
    alerts_count: Optional[int] = Field(None, ge=0)


class CityScoreResponse(CityScoreBase):
    """API'den dönen skor response şeması"""
    
    class Config:
        from_attributes = True


# ==================== FEEDBACK CATEGORY SCHEMAS ====================
class FeedbackCategoryBase(BaseModel):
    """Kategori için temel şema"""
    category: str = Field(..., description="Kategori adı")
    description: Optional[str] = Field(None, description="Açıklama")


class FeedbackCategoryCreate(FeedbackCategoryBase):
    """Yeni kategori oluştururken kullanılan şema"""
    pass


class FeedbackCategoryUpdate(BaseModel):
    """Kategori güncellerken kullanılan şema"""
    description: Optional[str] = None


class FeedbackCategoryResponse(FeedbackCategoryBase):
    """API'den dönen kategori response şeması"""
    
    class Config:
        from_attributes = True


# ==================== CITY FEEDBACK SCHEMAS ====================
class CityFeedbackBase(BaseModel):
    """Kullanıcı mesajı için temel şema"""
    city_id: str
    user: str = Field(..., description="Kullanıcı adı")
    message: str = Field(..., description="Mesaj içeriği")
    category: str = Field(..., description="Kategori")


class CityFeedbackCreate(CityFeedbackBase):
    """Yeni feedback oluştururken kullanılan şema"""
    pass


class CityFeedbackUpdate(BaseModel):
    """Feedback güncellerken kullanılan şema"""
    user: Optional[str] = None
    message: Optional[str] = None
    category: Optional[str] = None


class CityFeedbackResponse(CityFeedbackBase):
    """API'den dönen feedback response şeması"""
    id: int
    timestamp: datetime
    
    class Config:
        from_attributes = True
