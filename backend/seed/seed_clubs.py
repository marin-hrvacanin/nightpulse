"""
Seed script for populating the database with Zagreb clubs and genres.

Usage:
    cd backend
    python -m seed.seed_clubs
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import SessionLocal, engine, Base
from app.models.club import Club, Genre, ClubGenre

GENRES = [
    {"name": "Techno", "icon": "equalizer"},
    {"name": "House", "icon": "headphones"},
    {"name": "Pop", "icon": "music_note"},
    {"name": "Trap", "icon": "mic"},
    {"name": "R&B", "icon": "piano"},
]

CLUBS = [
    {
        "name": "THE CLUB",
        "slug": "the-club",
        "description": "Premium nightclub in the heart of Zagreb",
        "address": "Jabukovac 28, 10000 Zagreb",
        "latitude": 45.8131,
        "longitude": 15.9775,
        "genres": ["Techno", "House"],
    },
    {
        "name": "EX CLUB",
        "slug": "ex-club",
        "description": "Underground vibes and electronic music",
        "address": "Ulica kneza Branimira 29, 10000 Zagreb",
        "latitude": 45.8115,
        "longitude": 15.9740,
        "genres": ["House", "Pop"],
    },
    {
        "name": "GALLERY CLUB",
        "slug": "gallery-club",
        "description": "Stylish venue with top DJs and art installations",
        "address": "Masarykova 26, 10000 Zagreb",
        "latitude": 45.8145,
        "longitude": 15.9810,
        "genres": ["Pop", "Trap"],
    },
    {
        "name": "AQUARIUS",
        "slug": "aquarius",
        "description": "Iconic lakeside club on Jarun",
        "address": "Aleja Matije Ljubeka, 10000 Zagreb",
        "latitude": 45.7980,
        "longitude": 15.9450,
        "genres": ["Techno", "Trap"],
    },
    {
        "name": "BOOGALOO",
        "slug": "boogaloo",
        "description": "Large concert and club venue on lake Jarun",
        "address": "Ulica grada Vukovara 68, 10000 Zagreb",
        "latitude": 45.8050,
        "longitude": 15.9680,
        "genres": ["Techno"],
    },
    {
        "name": "MASTERS",
        "slug": "masters",
        "description": "Multi-floor party venue in city center",
        "address": "Tkalčićeva 59, 10000 Zagreb",
        "latitude": 45.8165,
        "longitude": 15.9770,
        "genres": ["Pop", "R&B"],
    },
    {
        "name": "JOHANN FRANCK",
        "slug": "johann-franck",
        "description": "Elegant lounge bar and club on main square",
        "address": "Trg bana Jelačića 9, 10000 Zagreb",
        "latitude": 45.8130,
        "longitude": 15.9770,
        "genres": ["House", "R&B"],
    },
    {
        "name": "MINT",
        "slug": "mint",
        "description": "Trendy club with modern sound system",
        "address": "Savska cesta 141, 10000 Zagreb",
        "latitude": 45.7915,
        "longitude": 15.9585,
        "genres": ["Techno", "House"],
    },
]


def seed():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # Seed genres
        genre_map = {}
        for g in GENRES:
            existing = db.query(Genre).filter(Genre.name == g["name"]).first()
            if existing:
                genre_map[g["name"]] = existing
            else:
                genre = Genre(**g)
                db.add(genre)
                db.flush()
                genre_map[g["name"]] = genre
                print(f"  + Genre: {g['name']}")

        # Seed clubs
        for c in CLUBS:
            genre_names = c.pop("genres")
            existing = db.query(Club).filter(Club.slug == c["slug"]).first()
            if existing:
                print(f"  ~ Club already exists: {c['name']}")
                continue

            club = Club(**c)
            club.genres = [genre_map[name] for name in genre_names]
            db.add(club)
            print(f"  + Club: {c['name']}")

        db.commit()
        print("\nSeed complete!")

    finally:
        db.close()


if __name__ == "__main__":
    seed()
