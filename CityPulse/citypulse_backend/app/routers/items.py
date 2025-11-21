from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from ..database import get_db
from .. import models, schemas
from ..utils import success_response, error_response


router = APIRouter(
    prefix="/api/items",  # /api/ prefix'i Flutter ile daha düzenli
    tags=["items"]
)


@router.post("/", status_code=status.HTTP_201_CREATED)
def create_item(item: schemas.ItemCreate, db: Session = Depends(get_db)):
    """Yeni bir item oluştur"""
    try:
        db_item = models.Item(**item.model_dump())
        db.add(db_item)
        db.commit()
        db.refresh(db_item)
        return success_response(
            data={
                "id": db_item.id,
                "name": db_item.name,
                "description": db_item.description,
                "price": db_item.price,
                "is_available": db_item.is_available
            },
            message="Item başarıyla oluşturuldu"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Item oluşturulurken hata: {str(e)}", "CREATE_ERROR")
        )


@router.get("/")
def get_items(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Tüm itemları listele"""
    try:
        items = db.query(models.Item).offset(skip).limit(limit).all()
        items_list = [
            {
                "id": item.id,
                "name": item.name,
                "description": item.description,
                "price": item.price,
                "is_available": item.is_available
            }
            for item in items
        ]
        return success_response(
            data=items_list,
            message=f"{len(items_list)} item bulundu"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"İtemlar getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.get("/{item_id}")
def get_item(item_id: int, db: Session = Depends(get_db)):
    """Belirli bir item'ı ID ile getir"""
    try:
        item = db.query(models.Item).filter(models.Item.id == item_id).first()
        if item is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"ID {item_id} ile item bulunamadı", "NOT_FOUND")
            )
        return success_response(
            data={
                "id": item.id,
                "name": item.name,
                "description": item.description,
                "price": item.price,
                "is_available": item.is_available
            },
            message="Item bulundu"
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Item getirilirken hata: {str(e)}", "FETCH_ERROR")
        )


@router.put("/{item_id}")
def update_item(item_id: int, item_update: schemas.ItemUpdate, db: Session = Depends(get_db)):
    """Bir item'ı güncelle"""
    try:
        db_item = db.query(models.Item).filter(models.Item.id == item_id).first()
        if db_item is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"ID {item_id} ile item bulunamadı", "NOT_FOUND")
            )
        
        # Sadece gönderilen alanları güncelle
        update_data = item_update.model_dump(exclude_unset=True)
        if not update_data:
            raise HTTPException(
                status_code=400,
                detail=error_response("Güncellenecek alan belirtilmedi", "NO_UPDATE_DATA")
            )
        
        for key, value in update_data.items():
            setattr(db_item, key, value)
        
        db.commit()
        db.refresh(db_item)
        
        return success_response(
            data={
                "id": db_item.id,
                "name": db_item.name,
                "description": db_item.description,
                "price": db_item.price,
                "is_available": db_item.is_available
            },
            message="Item başarıyla güncellendi"
        )
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Item güncellenirken hata: {str(e)}", "UPDATE_ERROR")
        )


@router.delete("/{item_id}")
def delete_item(item_id: int, db: Session = Depends(get_db)):
    """Bir item'ı sil"""
    try:
        db_item = db.query(models.Item).filter(models.Item.id == item_id).first()
        if db_item is None:
            raise HTTPException(
                status_code=404,
                detail=error_response(f"ID {item_id} ile item bulunamadı", "NOT_FOUND")
            )
        
        db.delete(db_item)
        db.commit()
        
        return success_response(
            data={"deleted_id": item_id},
            message="Item başarıyla silindi"
        )
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=error_response(f"Item silinirken hata: {str(e)}", "DELETE_ERROR")
        )
