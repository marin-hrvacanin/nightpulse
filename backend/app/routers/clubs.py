from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from ..database import get_db
from ..models.club import Club, Genre
from ..schemas.club import ClubOut, ClubListOut
from ..services.stats_service import get_live_stats
from ..services.geo_service import haversine_distance

router = APIRouter(prefix="/clubs", tags=["Clubs"])


@router.get("", response_model=list[ClubListOut])
def list_clubs(
    genre: str | None = None,
    search: str | None = None,
    db: Session = Depends(get_db),
):
    query = db.query(Club).options(joinedload(Club.genres))

    if genre:
        query = query.filter(Club.genres.any(Genre.name.ilike(genre)))

    if search:
        query = query.filter(Club.name.ilike(f"%{search}%"))

    clubs = query.order_by(Club.name).all()

    results = []
    for club in clubs:
        club_data = ClubListOut.model_validate(club)
        club_data.live_stats = get_live_stats(db, club.id)
        results.append(club_data)

    return results


@router.get("/nearby", response_model=list[ClubListOut])
def nearby_clubs(
    lat: float = Query(..., description="User latitude"),
    lng: float = Query(..., description="User longitude"),
    radius: int = Query(300, description="Radius in meters"),
    db: Session = Depends(get_db),
):
    all_clubs = db.query(Club).options(joinedload(Club.genres)).all()

    nearby = []
    for club in all_clubs:
        dist = haversine_distance(lat, lng, club.latitude, club.longitude)
        if dist <= radius:
            club_data = ClubListOut.model_validate(club)
            club_data.live_stats = get_live_stats(db, club.id)
            nearby.append(club_data)

    return nearby


@router.get("/{club_id}", response_model=ClubOut)
def get_club(club_id: int, db: Session = Depends(get_db)):
    club = db.query(Club).options(joinedload(Club.genres)).filter(Club.id == club_id).first()
    if not club:
        raise HTTPException(status_code=404, detail="Club not found")

    club_data = ClubOut.model_validate(club)
    club_data.live_stats = get_live_stats(db, club.id)
    return club_data
