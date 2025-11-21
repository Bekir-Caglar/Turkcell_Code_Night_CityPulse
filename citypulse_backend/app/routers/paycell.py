from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import date

from ..database import get_db
from .. import models, schemas
from ..utils import success_response, error_response


router = APIRouter(
    prefix="/api/paycell",
    tags=["paycell"]
)

# NOT: Sadece READ işlemleri - CREATE/UPDATE/DELETE YOK


@router.get("/")
def get_all_paycell(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Tüm Paycell verilerini listele"""
    try:
        paycell_data = db.query(models.PaycellStats).offset(skip).limit(limit).all()
        paycell_list = [
            {
                "city_id": p.city_id,
                "date": str(p.date),
                "transactions_count": p.transactions_count,
                "total_amount": p.total_amount
            }
            for p in paycell_data
        ]
        return success_response(
            data=paycell_list,
            message=f"{len(paycell_list)} Paycell verisi bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Paycell verileri getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}")
def get_city_paycell(city_id: str, db: Session = Depends(get_db)):
    """Belirli bir şehrin tüm Paycell verilerini getir"""
    try:
        paycell_data = db.query(models.PaycellStats).filter(
            models.PaycellStats.city_id == city_id
        ).all()
        
        paycell_list = [
            {
                "city_id": p.city_id,
                "date": str(p.date),
                "transactions_count": p.transactions_count,
                "total_amount": p.total_amount
            }
            for p in paycell_data
        ]
        
        return success_response(
            data=paycell_list,
            message=f"{len(paycell_list)} Paycell verisi bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Paycell verileri getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{city_id}/{date}")
def get_paycell_by_date(city_id: str, date: date, db: Session = Depends(get_db)):
    """Belirli bir şehir ve tarihe ait Paycell verisini getir"""
    try:
        paycell = db.query(models.PaycellStats).filter(
            models.PaycellStats.city_id == city_id,
            models.PaycellStats.date == date
        ).first()
        
        if paycell is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"Bu şehir ve tarih için Paycell verisi bulunamadı", "NOT_FOUND")
            )
        
        return success_response(
            data={
                "city_id": paycell.city_id,
                "date": str(paycell.date),
                "transactions_count": paycell.transactions_count,
                "total_amount": paycell.total_amount
            },
            message="Paycell verisi bulundu"
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Paycell verisi getirilirken hata: {str(e)}", "FETCH_ERROR")
        )
