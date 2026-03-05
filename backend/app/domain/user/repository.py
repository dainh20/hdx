from sqlalchemy.orm import Session
from .models import User

class UserRepository:

    def get_by_username(self, db: Session, username: str):
        return db.query(User).filter(User.username == username).first()

    def create(self, db: Session, data: dict):
        user = User(**data)
        db.add(user)
        db.commit()
        db.refresh(user)
        return user