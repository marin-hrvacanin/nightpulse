from pydantic import BaseModel
from datetime import datetime


class UserOut(BaseModel):
    id: int
    email: str
    full_name: str | None
    avatar_url: str | None
    preferences: dict
    created_at: datetime

    model_config = {"from_attributes": True}


class UserUpdate(BaseModel):
    full_name: str | None = None
    avatar_url: str | None = None


class PreferencesUpdate(BaseModel):
    genres: list[str]
