from pydantic import BaseModel
from datetime import datetime


class GenreOut(BaseModel):
    id: int
    name: str
    icon: str | None

    model_config = {"from_attributes": True}


class LiveStats(BaseModel):
    crowd_avg: float | None = None
    atmosphere_avg: float | None = None
    top_genre: str | None = None
    wait_minutes_avg: float | None = None
    review_count: int = 0
    last_updated: datetime | None = None


class ClubOut(BaseModel):
    id: int
    name: str
    slug: str
    description: str | None
    address: str | None
    latitude: float
    longitude: float
    photo_url: str | None
    genres: list[GenreOut]
    live_stats: LiveStats | None = None

    model_config = {"from_attributes": True}


class ClubListOut(BaseModel):
    id: int
    name: str
    slug: str
    latitude: float
    longitude: float
    photo_url: str | None
    genres: list[GenreOut]
    live_stats: LiveStats | None = None

    model_config = {"from_attributes": True}
