from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import date

from ..database import get_db
from .. import models, schemas
from ..utils import success_response, error_response


router = APIRouter(
    prefix="/api/scores",
    tags=["scores"]
)

# NOT: Sadece READ işlemleri - CREATE/UPDATE/DELETE YOK


@router.get("/")
def get_all_scores(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Tüm skor verilerini listele"""
    try:
        scores = db.query(models.CityScore).offset(skip).limit(limit).all()
        scores_list = [
            {
                "city_id": s.city_id,
                "date": str(s.date),
                "eco_score": s.eco_score,
                "alerts_count": s.alerts_count
            }
            for s in scores
        ]
        return success_response(
            data=scores_list,
            message=f"{len(scores_list)} skor verisi bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Skor verileri getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}")
def get_city_scores(city_id: str, db: Session = Depends(get_db)):
    """Belirli bir şehrin tüm skor verilerini getir"""
    try:
        scores = db.query(models.CityScore).filter(
            models.CityScore.city_id == city_id
        ).all()
        
        scores_list = [
            {
                "city_id": s.city_id,
                "date": str(s.date),
                "eco_score": s.eco_score,
                "alerts_count": s.alerts_count
            }
            for s in scores
        ]
        
        return success_response(
            data=scores_list,
            message=f"{len(scores_list)} skor verisi bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Skor verileri getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}/{date}")
def get_score_by_date(city_id: str, date: date, db: Session = Depends(get_db)):
    """Belirli bir şehir ve tarihe ait skor verisini getir"""
    try:
        score = db.query(models.CityScore).filter(
            models.CityScore.city_id == city_id,
            models.CityScore.date == date
        ).first()
        
        if score is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Bu şehir ve tarih için skor bulunamadı", "NOT_FOUND")
            )
        
        return success_response(
            data={
                "city_id": score.city_id,
                "date": str(score.date),
                "eco_score": score.eco_score,
                "alerts_count": score.alerts_count
            },
            message="Skor bulundu"
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Skor getirilirken hata: {str(e)}", "FETCH_ERROR")
        )
