# Vedic Kundali & Astrology Backend API

A high-performance Laravel backend providing RESTful APIs for Vedic Kundali calculations, Ashtakoot Gun Milan matchmaking, Indian city autocomplete (146,000+ SQLite database), and PDF report generation.

---

## 🚀 Astronomy Engine (`astroengine`)

The calculation core uses a high-precision C engine based on Don Cross's Astronomy Engine (`engine/astroengine`), which calculates planetary positions, houses, rashis, and nakshatras with arcsecond accuracy.

- **Binary Location:** `engine/astroengine` (invoked by `App\Services\Astrology\AstronomyEngine`)
- **Source Code Directory:** `engine/astronomy/`
  - `astroengine.c` — Main C CLI entrypoint
  - `astronomy.c` & `astronomy.h` — Astronomical ephemeris engine
  - `build.sh` — Linux build script
  - `build.bat` — Windows build script

---

## 🛠️ How to Compile / Build the Engine

When deploying to a new server (such as AWS Lightsail, Ubuntu, Debian, or CentOS), **always recompile the engine on that server** to link against the server's native `glibc` library and avoid `GLIBC_X.XX not found` errors.

### 1. On Linux / AWS Lightsail (Ubuntu / Debian LAMP)

#### Step 1: Install build tools (GCC)
```bash
sudo apt update
sudo apt install -y build-essential gcc
```

#### Step 2: Navigate to the astronomy source folder
```bash
cd engine/astronomy
# or from server root:
# cd /var/www/html/backend/engine/astronomy
```

#### Step 3: Recompile the binary
```bash
gcc -O3 astroengine.c astronomy.c -lm -o ../astroengine
```
*(Or simply run `bash build.sh`)*

#### Step 4: Grant execution and web-server permissions
```bash
chmod +x ../astroengine
# If deploying under Apache / Nginx:
sudo chown www-data:www-data ../astroengine
```

#### Step 5: Test the binary directly
Verify that the engine runs cleanly and outputs JSON:
```bash
../astroengine 2000-09-06 14:00:00 21.35 74.88 lahiri
```
You should see a clean JSON response containing planetary longitudes, rashis, and houses.

---

### 2. On Windows (Development)

Using MinGW / GCC on Windows:
```cmd
cd engine\astronomy
build.bat
```
or manually:
```cmd
gcc -O3 astroengine.c astronomy.c -lm -o ..\astroengine.exe
```

---

## ⚠️ Troubleshooting `GLIBC_X.XX not found` Error

If you see an error like:
```text
Calculation error: Astronomy Engine returned invalid output:
/var/www/html/backend/engine/astroengine: /lib/x86_64-linux-gnu/libm.so.6: version `GLIBC_2.38' not found
```

### Cause:
The `astroengine` binary was compiled on a development machine with a newer GLIBC version (e.g. Ubuntu 23.10/24.04 with GLIBC 2.38) and copied to an LTS server (e.g. Ubuntu 20.04/22.04 with GLIBC 2.31 or 2.35).

### Fix:
SSH into your AWS Lightsail or production server and compile the source code directly on that server:
```bash
cd /var/www/html/backend/engine/astronomy
gcc -O3 astroengine.c astronomy.c -lm -o ../astroengine
chmod +x ../astroengine
```

---

## 💻 Server Requirements & Setup

- **PHP:** 8.2 or higher
- **Extensions:** `pdo_sqlite`, `sqlite3`, `gd` or `imagick`, `mbstring`, `json`, `curl`
- **Compiler:** `gcc` (for building the C engine)

### Installation:

```bash
# 1. Install Composer dependencies
composer install --no-dev --optimize-autoloader

# 2. Environment Configuration
cp .env.example .env
php artisan key:generate

# 3. Ensure storage permissions
sudo chown -R www-data:www-data /var/www/html/backend
sudo chmod -R 775 /var/www/html/backend/storage
sudo chmod -R 775 /var/www/html/backend/bootstrap/cache
php artisan view:clear
php artisan cache:clear

# 4. Compile the engine (if not done already)
cd engine/astronomy && gcc -O3 astroengine.c astronomy.c -lm -o ../astroengine && cd ../..
chmod +x engine/astroengine
```

---

## 🧪 Running Automated Tests

Run the full Pest/PHPUnit test suite:
```bash
php artisan test
```

---

## 📡 API Endpoints Reference

All endpoints accept and return `application/json` (except PDF downloads which return binary `application/pdf`).

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/cities?q={query}&limit={n}` | Autocomplete search across 146,000+ Indian cities and villages in SQLite |
| `POST` | `/api/calculate` | Full Vedic Kundali calculation (Planets, Panchang, 4 Charts, Mahadasha) |
| `POST` | `/api/gunmilan` | 36-point Ashtakoot matchmaking with Bhav Chalit Mangal Dosha analysis |
| `POST` | `/api/download-pdf` | Generates & streams print-ready A4 Vedic Kundali PDF report |
| `POST` | `/api/download-gunmilan-pdf` | Generates & streams complete Gun Milan PDF report |
