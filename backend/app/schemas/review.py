from pydantic import BaseModel, field_validator
from datetime import datetime


class ReviewCreate(BaseModel):
    club_id: int
    crowd_rating: int
    atmosphere_rating: int
    music_genre: str
    wait_minutes: int
    latitude: float
    longitude: float

    @field_validator("crowd_rating", "atmosphere_rating")
    @classmethod
    def validate_rating(cls, v: int) -> int:
        if not 1 <= v <= 5:
            raise ValueError("Rating must be between 1 and 5")
        return v

    @field_validator("wait_minutes")
    @classmethod
    def validate_wait(cls, v: int) -> int:
        if not 0 <= v <= 20:
            raise ValueError("Wait minutes must be between 0 and 20")
        return v


class ReviewOut(BaseModel):
    id: int
    club_id: int
    crowd_rating: int
    atmosphere_rating: int
    music_genre: str | None
    wait_minutes: int
    created_at: datetime

    model_config = {"from_attributes": True}
