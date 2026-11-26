# Vedic Kundali — Vedic Astrology App with Live Flagsmith A/B Experimentation

Built for **Toggle Wars: The Flagsmith Experimentation Hackathon (Track 1: Test Something Real)** by WeMakeDevs × Flagsmith.

Vedic Kundali is a full-stack Vedic astrology application featuring a **Laravel 13 + C Ephemeris Engine** backend and a **Flutter** mobile frontend (supporting Marathi, Hindi, and English), powered by **Flagsmith Experimentation** to optimize user engagement and PDF report downloads.

---

## 🧪 Flagsmith A/B Experiment: Kundali Result Layout

### Hypothesis
> *"Presenting a simplified, summary-first Kundali overview with key highlights (Rashi, Nakshatra, Lagna, Mahadasha) and a prominent PDF download CTA will increase PDF report download conversions compared to immediately showing the full 5-tab detailed view."*

### Experiment Configuration
| Parameter | Details |
|---|---|
| **Feature Flag** | `kundali_result_layout` (Multivariate) |
| **Control (`detailed`, 50%)** | Full 5-tab view (`KundaliResultScreen`) showing Charts, Panchang, Planets, Mahadasha, and Avakhada immediately |
| **Test (`summary_first`, 50%)** | Summary-first view (`SummaryResultView`) highlighting core insights, an above-the-fold PDF CTA, and expandable full details |
| **User Identification** | Authenticated user email (`AuthService.userEmail`) for consistent cross-session bucketing |
| **Primary Metric** | `pdf_download` — tracked when a user downloads the Kundali PDF report |
| **Secondary Metric** | `view_full_details` — tracked when a user in the `summary_first` variant expands the full details section |

---

## ⚙️ How Flagsmith Is Integrated

### 1. Mobile App (Flutter — `flagsmith: ^6.4.0`)
- **Initialization** ([`mobile/lib/main.dart`](mobile/lib/main.dart), [`mobile/lib/services/flagsmith_service.dart`](mobile/lib/services/flagsmith_service.dart)): Initializes `FlagsmithClient` with `enableEvents: true` so native Flagsmith exposure and conversion events are buffered and flushed to `https://events.api.flagsmith.com/`.
- **Identity Sync** ([`login_screen.dart`](mobile/lib/screens/auth/login_screen.dart), [`signup_screen.dart`](mobile/lib/screens/auth/signup_screen.dart), [`settings_screen.dart`](mobile/lib/screens/settings/settings_screen.dart)): Calls `FlagsmithService.identifyUser()` on login/signup and `FlagsmithService.clearUser()` on logout.
- **Experiment Routing & Exposure** ([`experiment_result_router.dart`](mobile/lib/screens/kundali/experiment_result_router.dart)): Calls `getExperimentFlag('kundali_result_layout')`, automatically recording a `$flag_exposure` event with the assigned variant and `experiment_id` before rendering either `KundaliResultScreen` or `SummaryResultView`.
- **Conversion Tracking** ([`kundali_result_screen.dart`](mobile/lib/screens/kundali/kundali_result_screen.dart), [`summary_result_view.dart`](mobile/lib/screens/kundali/summary_result_view.dart)): Calls `FlagsmithService.trackConversion('pdf_download')` and immediately flushes events to Flagsmith.

### 2. Backend API (Laravel 13 — `flagsmith/flagsmith-php-client: ^5.5`)
- **Service Wrapper** ([`backend/app/Services/Flagsmith/FlagsmithService.php`](backend/app/Services/Flagsmith/FlagsmithService.php)): Configures `Flagsmith` with the server-side key and `enableEvents: true`.
- **Server-Side Audit Logging** ([`backend/app/Http/Controllers/Api/PdfController.php`](backend/app/Http/Controllers/Api/PdfController.php)): Resolves the user's assigned `kundali_result_layout` variant on `/api/download-pdf` requests for server-side audit logs.

---

## 🛠️ Setup & Installation

### Prerequisites
- PHP 8.3+ & Composer
- Flutter SDK 3.14+
- GCC / Make (for compiling the C astronomy engine if needed)
- A Flagsmith project with a multivariate flag named `kundali_result_layout` (`detailed` 50%, `summary_first` 50%)

### 1. Backend Setup (Laravel)
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
```

Add your Flagsmith keys to `backend/.env`:
```env
FLAGSMITH_SERVER_KEY=ser.your_server_side_key
FLAGSMITH_CLIENT_KEY=your_client_side_key
```

Start the API server:
```bash
php artisan serve
```

### 2. Mobile Setup (Flutter)
```bash
cd mobile
flutter pub get
```

Run the app (optionally passing your Flagsmith client key):
```bash
flutter run --dart-define=FLAGSMITH_CLIENT_KEY=your_client_side_key
```

---

## ✅ Running Tests

```bash
# Backend tests
cd backend && php artisan test

# Mobile static analysis & tests
cd mobile && flutter analyze && flutter test
```

---

## 📱 Core Features
- **Kundali Generation:** Lahiri & KP Ayanamsha, North Indian Diamond Charts (Lagna, Navamsha, Chalit, Chandra), Panchang, Hindu Calendar, Vimshottari Mahadasha, and Avakhada Chakra
- **Gun Milan Matchmaking:** 36-point Ashtakoot compatibility & Mangal Dosha analysis
- **PDF Reports:** Multi-language PDF generation via mPDF
- **Offline Indian Cities Database:** Fast city/latitude/longitude lookup
- **Multi-language Support:** Marathi (`mr`), Hindi (`hi`), and English (`en`)
