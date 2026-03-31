# CLAUDE.md - NightPulse Development Context

## Project Summary

NightPulse is a real-time nightlife discovery app ("Waze for clubbing"). Users see live crowdsourced data about clubs — crowd levels, music genre, entry price, queue times — and can submit reviews when physically near a venue (GPS-enforced 300m radius).

**Target market:** Zagreb, Croatia (initial launch), expandable to other cities.

## Tech Stack

### Frontend (Flutter)
- **Framework:** Flutter 3.41+ / Dart 3.11+
- **State management:** StatefulWidget (no external state library yet)
- **Key packages:** `google_fonts`, `flutter_map`, `latlong2`, `flutter_svg`, `http`
- **Theme:** Dark mode only, neon green/cyan gradient palette
- **Language:** Croatian (all user-facing strings)

### Backend (Python)
- **Framework:** FastAPI 0.131
- **ORM:** SQLAlchemy 2.0
- **Auth:** passlib + bcrypt (registration only, no login/JWT yet)
- **Validation:** Pydantic v2 + email-validator
- **Server:** Uvicorn

### Infrastructure (Azure)
- **Database:** Azure Database for PostgreSQL (server: `nightpulse26.postgres.database.azure.com`)
- **Secrets:** Azure Key Vault (planned, credentials currently in `.env`)
- **Deployment:** Not yet configured (no Docker, no CI/CD)

## Project Structure

```
NightPulse/
├── backend/
│   ├── app/
│   │   ├── main.py          # FastAPI app, 2 endpoints (/example, /register)
│   │   ├── models.py        # SQLAlchemy models (User only)
│   │   └── database.py      # PostgreSQL connection via SQLAlchemy
│   ├── requirements.txt
│   ├── .env                 # DB credentials (gitignored)
│   └── .env.example
├── frontend/
│   ├── lib/
│   │   ├── main.dart        # App entry point
│   │   ├── theme/app_theme.dart
│   │   ├── models/club.dart
│   │   ├── data/mock_data.dart    # 5 hardcoded Zagreb clubs
│   │   ├── services/api_service.dart
│   │   ├── screens/
│   │   │   ├── auth/              # login, signup, onboarding
│   │   │   ├── home_screen.dart   # Discovery feed
│   │   │   ├── map_screen.dart    # Club map (CartoDB dark tiles)
│   │   │   ├── live_review_screen.dart  # Post reviews
│   │   │   ├── favourites_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── main_shell.dart    # Bottom nav (5 tabs)
│   │   └── widgets/               # club_card, glass_container, custom_button
│   ├── assets/
│   │   ├── clubs/                 # Club photos (club1.jpg, club2.jpg, club3.jpg)
│   │   └── logo/                  # nightpulse_logo.svg
│   └── pubspec.yaml
├── CLAUDE.md
├── README.md
├── ARCHITECTURE.md
└── ROADMAP.md
```

## Development Commands

### Frontend
```bash
cd frontend
flutter pub get              # Install dependencies
flutter run -d <device>      # Run on device/emulator
flutter build apk --debug    # Build Android debug APK
flutter build web            # Build web version
```

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate     # or venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Build Quirks (Windows)

- **Path spaces:** The user's home dir has a space (`Gostinska soba`). This breaks Flutter's native asset builder with `objective_c` package. Fixed by pinning `path_provider_foundation: 2.4.0` in `dependency_overrides`.
- **JAVA_HOME:** Set via `org.gradle.java.home` in `frontend/android/gradle.properties` using 8.3 short path: `C:/PROGRA~1/ECLIPS~1/JDK-17~1.8-H`
- **Android SDK:** Located at `C:\Android\` (no spaces).

## Current State

- **Frontend:** Polished UI with 5 screens, dark theme, mock data. No live API integration.
- **Backend:** Skeleton with user registration. No JWT auth, no club/review endpoints.
- **Infrastructure:** Azure PostgreSQL provisioned. No containerization, no CI/CD, no Key Vault integration.
- **Data:** All club data is hardcoded in `mock_data.dart`. No real-time data flow.

## Conventions

- **UI language:** Croatian (all user-facing text)
- **Code language:** English (variable names, comments, docs)
- **Git:** Single `main` branch, no PR workflow established yet
- **Git remote:** `https://github.com/marin-hrvacanin/nightpulse.git`

## Important Notes

- Never commit `.env` files — they contain production database credentials
- The `backend/.env` is already in `.gitignore`
- Frontend uses `flutter_map` with CartoDB dark tiles (no API key needed)
- Club model has `imageAsset` field for local photos, `gradientColors` as fallback
- The "Post" tab in the bottom nav has a special highlighted circular design (primary feature)
