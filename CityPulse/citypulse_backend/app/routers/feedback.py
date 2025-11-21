from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional

from ..database import get_db
from .. import models, schemas
from ..utils import success_response, error_response
from ..feedback_classifier import kategori_bul, kategori_detayli_analiz


router = APIRouter(
    prefix="/api/feedback",
    tags=["feedback"]
)


class FeedbackFromFlutter(BaseModel):
    """Flutter'dan gelen feedback modeli"""
    city_id: str = Field(..., description="Şehir ID (plaka kodu)")
    message: str = Field(..., min_length=1, description="Kullanıcı mesajı")
    timestamp: Optional[str] = Field(None, description="Zaman damgası (opsiyonel)")


@router.post("/submit")
def submit_feedback_from_flutter(
    feedback: FeedbackFromFlutter,
    db: Session = Depends(get_db)
):
    """
    Flutter'dan feedback al, kategoriyi otomatik belirle ve veritabanına kaydet
    
    Flutter'dan gelen JSON:
    {
        "city_id": "06",
        "message": "Gazi Mahallesi girişinde sinyalizasyon aksaklığı var.",
        "timestamp": "2025-11-20 10:00:00"  // Opsiyonel
    }
    
    Backend otomatik olarak:
    - Kategoriyi belirler (Trafik, Çevre, Bağlantı, Öneri)
    - User ID'yi oluşturur
    - Veritabanına kaydeder
    """
    try:
        # 1. Şehir var mı kontrol et
        city = db.query(models.City).filter(models.City.city_id == feedback.city_id).first()
        if not city:
            raise HTTPException(
                status_code=404,
                detail=error_response(
                    f"Şehir ID {feedback.city_id} bulunamadı",
                    "CITY_NOT_FOUND"
                )
            )
        
        # 2. Mesajdan kategori belirle (Kural tabanlı NLP)
        kategori_analizi = kategori_detayli_analiz(feedback.message)
        belirlenen_kategori = kategori_analizi['kategori']
        
        # 3. Kategori veritabanında var mı kontrol et, yoksa oluştur
        category_obj = db.query(models.FeedbackCategory).filter(
            models.FeedbackCategory.category == belirlenen_kategori
        ).first()
        
        if not category_obj:
            # Kategori yoksa oluştur
            category_obj = models.FeedbackCategory(
                category=belirlenen_kategori,
                description=f"{belirlenen_kategori} kategorisi için feedback'ler"
            )
            db.add(category_obj)
            db.commit()
        
        # 4. Otomatik user ID oluştur (feedback sayısına göre)
        feedback_count = db.query(models.CityFeedback).count()
        auto_user = f"user_{feedback_count + 1}"
        
        # 5. Timestamp'i işle
        if feedback.timestamp:
            try:
                # String'den datetime'a çevir
                if isinstance(feedback.timestamp, str):
                    feedback_timestamp = datetime.strptime(
                        feedback.timestamp, 
                        "%Y-%m-%d %H:%M:%S"
                    )
                else:
                    feedback_timestamp = feedback.timestamp
            except:
                feedback_timestamp = datetime.now()
        else:
            feedback_timestamp = datetime.now()
        
        # 6. Feedback'i veritabanına kaydet
        new_feedback = models.CityFeedback(
            city_id=feedback.city_id,
            user=auto_user,
            message=feedback.message,
            category=belirlenen_kategori,
            timestamp=feedback_timestamp
        )
        
        db.add(new_feedback)
        db.commit()
        db.refresh(new_feedback)
        
        # 7. Response döndür
        return success_response(
            data={
                "id": new_feedback.id,
                "city_id": new_feedback.city_id,
                "city_name": city.name,
                "user": new_feedback.user,
                "message": new_feedback.message,
                "category": new_feedback.category,
                "timestamp": str(new_feedback.timestamp),
                "category_analysis": {
                    "detected_category": belirlenen_kategori,
                    "confidence_score": kategori_analizi['guven_skoru'],
                    "matched_keywords": kategori_analizi['bulunan_kelimeler'][:5]
                }
            },
            message="Feedback başarıyla kaydedildi ve kategorize edildi"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=error_response(
                f"Feedback kaydedilirken hata: {str(e)}",
                "FEEDBACK_SAVE_ERROR"
            )
        )


@router.get("/")
def get_all_feedback(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Tüm feedback'leri listele"""
    try:
        feedbacks = db.query(models.CityFeedback).offset(skip).limit(limit).all()
        feedback_list = [
            {
                "id": f.id,
                "city_id": f.city_id,
                "user": f.user,
                "message": f.message,
                "category": f.category,
                "timestamp": str(f.timestamp)
            }
            for f in feedbacks
        ]
        return success_response(
            data=feedback_list,
            message=f"{len(feedback_list)} feedback bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Feedback'ler getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{feedback_id}")
def get_feedback(feedback_id: int, db: Session = Depends(get_db)):
    """Belirli bir feedback'i getir"""
    try:
        feedback = db.query(models.CityFeedback).filter(models.CityFeedback.id == feedback_id).first()
        if feedback is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Feedback ID {feedback_id} bulunamadı", "NOT_FOUND")
            )
        
        return success_response(
            data={
                "id": feedback.id,
                "city_id": feedback.city_id,
                "user": feedback.user,
                "message": feedback.message,
                "category": feedback.category,
                "timestamp": str(feedback.timestamp)
            },
            message="Feedback bulundu"
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Feedback getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/city/{city_id}")
def get_city_feedback(city_id: str, db: Session = Depends(get_db)):
    """Belirli bir şehrin tüm feedback'lerini getir"""
    try:
        feedbacks = db.query(models.CityFeedback).filter(
            models.CityFeedback.city_id == city_id
        ).all()
        
        feedback_list = [
            {
                "id": f.id,
                "city_id": f.city_id,
                "user": f.user,
                "message": f.message,
                "category": f.category,
                "timestamp": str(f.timestamp)
            }
            for f in feedbacks
        ]
        
        return success_response(
            data=feedback_list,
            message=f"{len(feedback_list)} feedback bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Feedback'ler getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


# DELETE kaldırıldı - READ-ONLY mod


# ==================== FEEDBACK CATEGORIES ====================
categories_router = APIRouter(
    prefix="/api/categories",
    tags=["categories"]
)

# CREATE kaldırıldı - READ-ONLY mod


@categories_router.get("/")
def get_all_categories(db: Session = Depends(get_db)):
    """Tüm kategorileri listele"""
    try:
        categories = db.query(models.FeedbackCategory).all()
        category_list = [
            {
                "category": c.category,
                "description": c.description
            }
            for c in categories
        ]
        return success_response(
            data=category_list,
            message=f"{len(category_list)} kategori bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Kategoriler getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@categories_router.get("/{category_name}")
def get_category(category_name: str, db: Session = Depends(get_db)):
    """Belirli bir kategoriyi getir"""
    try:
        category = db.query(models.FeedbackCategory).filter(
            models.FeedbackCategory.category == category_name
        ).first()
        
        if category is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Kategori '{category_name}' bulunamadı", "NOT_FOUND")
            )
        
        return success_response(
            data={
                "category": category.category,
                "description": category.description
            },
            message="Kategori bulundu"
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Kategori getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


# DELETE kaldırıldı - READ-ONLY mod
