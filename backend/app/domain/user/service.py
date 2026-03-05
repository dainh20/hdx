from app.core.security import hash_password, verify_password, create_access_token
from .repository import UserRepository

class UserService:

    def __init__(self):
        self.repo = UserRepository()

    def register(self, db, data):
        existing = self.repo.get_by_username(db, data["username"])
        if existing:
            raise Exception("Username already exists")

        data["password_hash"] = hash_password(data["password"])
        data.pop("password")
        data["status"] = "ACTIVE"

        return self.repo.create(db, data)

    def login(self, db, username, password):
        user = self.repo.get_by_username(db, username)
        if not user:
            raise Exception("Invalid credentials")

        if not verify_password(password, user.password_hash):
            raise Exception("Invalid credentials")

        token = create_access_token({"sub": str(user.id)})

        return {"access_token": token}