from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from ..database import get_db
from ..models.user import User
from ..models.club import Club
from ..models.favourite import Favourite
from ..schemas.club import ClubListOut
from ..middleware.auth import get_current_user
from ..services.stats_service import get_live_stats

router = APIRouter(prefix="/favourites", tags=["Favourites"])


@router.get("", response_model=list[ClubListOut])
def list_favourites(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    favs = (
        db.query(Favourite)
        .filter(Favourite.user_id == current_user.id)
        .options(joinedload(Favourite.club).joinedload(Club.genres))
        .order_by(Favourite.created_at.desc())
        .all()
    )

    results = []
    for fav in favs:
        club_data = ClubListOut.model_validate(fav.club)
        club_data.live_stats = get_live_stats(db, fav.club.id)
        results.append(club_data)

    return results


@router.post("/{club_id}", status_code=status.HTTP_201_CREATED)
def add_favourite(
    club_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    club = db.query(Club).filter(Club.id == club_id).first()
    if not club:
        raise HTTPException(status_code=404, detail="Club not found")

    existing = (
        db.query(Favourite)
        .filter(Favourite.user_id == current_user.id, Favourite.club_id == club_id)
        .first()
    )
    if existing:
        raise HTTPException(status_code=409, detail="Already in favourites")

    fav = Favourite(user_id=current_user.id, club_id=club_id)
    db.add(fav)
    db.commit()
    return {"message": "Added to favourites"}


@router.delete("/{club_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_favourite(
    club_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    fav = (
        db.query(Favourite)
        .filter(Favourite.user_id == current_user.id, Favourite.club_id == club_id)
        .first()
    )
    if not fav:
        raise HTTPException(status_code=404, detail="Not in favourites")

    db.delete(fav)
    db.commit()
