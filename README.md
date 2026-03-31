# NightPulse

Real-time nightlife discovery app — "Waze for clubbing."

Users see live crowdsourced data about clubs (crowd level, music genre, entry price, queue time) and can submit reviews when physically at a venue.

## Quick Start

### Prerequisites

- Flutter SDK 3.41+
- Python 3.11+
- PostgreSQL (local or Azure)
- Android SDK (for mobile builds)

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configure database
cp .env.example .env
# Edit .env with your database credentials

uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API docs available at `http://localhost:8000/docs` (Swagger UI).

### Frontend

```bash
cd frontend
flutter pub get
flutter run                     # Runs on connected device/emulator
```

**Android emulator:**
```bash
flutter run -d emulator-5554
```

**Build APK for sharing:**
```bash
flutter build apk --debug
# Output: frontend/build/app/outputs/flutter-apk/app-debug.apk
```

## Project Structure

```
NightPulse/
├── backend/          # FastAPI + SQLAlchemy + PostgreSQL
├── frontend/         # Flutter mobile app (Android/iOS/Web)
├── ARCHITECTURE.md   # System design, DB schema, API spec
├── ROADMAP.md        # Phased development plan
└── CLAUDE.md         # AI-assisted development context
```

## Tech Stack

| Layer          | Technology                          |
|----------------|-------------------------------------|
| Mobile App     | Flutter / Dart                      |
| Backend API    | Python / FastAPI                    |
| Database       | PostgreSQL (Azure)                  |
| Auth           | JWT (bcrypt password hashing)       |
| Maps           | flutter_map + CartoDB dark tiles    |
| Infrastructure | Azure (App Service, Key Vault, Blob)|

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full system design including:
- Database schema (users, clubs, reviews, favourites)
- REST API specification (15 endpoints)
- Azure infrastructure layout
- Security model
- Scalability path

## Roadmap

See [ROADMAP.md](ROADMAP.md) for the phased development plan.

## Team

- **GitHub:** [marin-hrvacanin/nightpulse](https://github.com/marin-hrvacanin/nightpulse)

## Development Notes

**Windows path quirk:** If your user directory has spaces, add this to `pubspec.yaml`:
```yaml
dependency_overrides:
  path_provider_foundation: 2.4.0
```

**Android emulator setup:**
```bash
sdkmanager "emulator" "system-images;android-34;google_apis;x86_64"
avdmanager create avd -n Pixel_7 -k "system-images;android-34;google_apis;x86_64" -d "pixel_7"
emulator -avd Pixel_7
```
