<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Astronomy Engine Binary Path
    |--------------------------------------------------------------------------
    | Path to the compiled C native binary (astroengine or astroengine.exe).
    */
    'binary_path' => env('ASTROENGINE_BIN_PATH', base_path('engine/astroengine')),

    /*
    |--------------------------------------------------------------------------
    | Cities Database & Fallback
    |--------------------------------------------------------------------------
    | SQLite database containing Indian cities/villages coordinates, and
    | optional fallback JSON stream path.
    */
    'cities_db' => env('CITIES_DB_PATH', database_path('data/cities.db')),
    'cities_json' => env('CITIES_JSON_PATH', database_path('data/cities.json')),

    /*
    |--------------------------------------------------------------------------
    | Default Ayanamsha & Timezone
    |--------------------------------------------------------------------------
    */
    'default_ayanamsha' => env('ASTROLOGY_DEFAULT_AYANAMSHA', 'lahiri'),
    'default_timezone' => env('ASTROLOGY_DEFAULT_TIMEZONE', 'Asia/Kolkata'),
];
