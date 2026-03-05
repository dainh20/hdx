from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from .service import UserService

router = APIRouter(prefix="/auth", tags=["auth"])
service = UserService()

@router.post("/register")
def register(data: dict, db: Session = Depends(get_db)):
    try:
        return service.register(db, data)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/login")
def login(data: dict, db: Session = Depends(get_db)):
    try:
        return service.login(db, data["username"], data["password"])
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))