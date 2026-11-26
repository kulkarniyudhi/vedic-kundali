/**
 * Astronomy Engine CLI for Vedic Kundali Software.
 * Powered by Astronomy Engine (by Don Cross, MIT License).
 * Provides high-precision planetary positions, Lahiri/KP Ayanamsha,
 * Ascendant (Lagna), and House Cusps for Vedic Astrology calculations.
 *
 * Usage:
 *   ./astroengine <YYYY-MM-DD> <HH:MM:SS> <latitude> <longitude> [ayanamsha]
 * Example:
 *   ./astroengine 1995-05-15 09:00:00 19.0760 72.8777 lahiri
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <strings.h>
#include "astronomy.h"

#define PI 3.14159265358979323846

static double norm360(double d) {
    d = fmod(d, 360.0);
    if (d < 0.0) d += 360.0;
    return d;
}

// Compute Lahiri Ayanamsha (Chitra Paksha) in degrees
static double compute_lahiri_ayanamsha(double jd) {
    double T = (jd - 2451545.0) / 36525.0;
    // Standard Indian Astronomical Ephemeris polynomial
    double ayan = 23.856808 + 1.3969713 * T + 0.0003086 * T * T;
    return ayan;
}

// Compute True Lunar Node (Rahu) in Sayana (Tropical) degrees
static double compute_true_rahu(double jd) {
    double T = (jd - 2451545.0) / 36525.0;
    double omega_mean = 125.044522 - 1934.136261 * T + 0.0020708 * T * T + 2.2e-6 * T * T * T;
    
    double M_sun = (357.529109 + 35999.050290 * T - 0.0001536 * T * T) * DEG2RAD;
    double M_moon = (134.963396 + 477198.867505 * T + 0.0087414 * T * T) * DEG2RAD;
    double F = (93.272095 + 483202.017523 * T - 0.0036539 * T * T) * DEG2RAD;
    double D = (297.850192 + 445267.111403 * T - 0.0018819 * T * T) * DEG2RAD;
    
    double pert = -1.4979 * sin(2.0 * (D - F))
                  - 0.1500 * sin(M_sun)
                  - 0.1226 * sin(2.0 * D)
                  + 0.1176 * sin(2.0 * F)
                  - 0.0801 * sin(2.0 * (M_moon - D));
                  
    return norm360(omega_mean + pert);
}

// Calculate True Obliquity of the Ecliptic (IAU formula)
static double compute_obliquity(double jd) {
    double T = (jd - 2451545.0) / 36525.0;
    double eps0 = 23.43929111 - 0.013004167 * T - 1.6389e-7 * T * T + 5.036e-7 * T * T * T;
    
    // Nutation in obliquity (dominant terms)
    double omega = (125.044522 - 1934.136261 * T) * DEG2RAD;
    double L_sun = (280.4665 + 36000.7698 * T) * DEG2RAD;
    double d_eps = (9.20 * cos(omega) + 0.57 * cos(2.0 * L_sun)) / 3600.0;
    
    return eps0 + d_eps;
}

// Calculate Tropical Ecliptic Longitude for a given body
static double get_body_ecliptic_lon(astro_body_t body, astro_time_t time) {
    if (body == BODY_SUN) {
        astro_ecliptic_t sun = Astronomy_SunPosition(time);
        return sun.elon;
    }
    astro_vector_t vec = Astronomy_GeoVector(body, time, ABERRATION);
    astro_ecliptic_t ecl = Astronomy_Ecliptic(vec);
    return ecl.elon;
}

// Calculate Placidus House Cusp (Sayana)
static double calc_placidus_cusp(int house, double armc_deg, double geolat_deg, double eps_deg) {
    double phi = geolat_deg * DEG2RAD;
    double eps = eps_deg * DEG2RAD;
    double f;
    int is_above;
    
    if (house == 11) {
        f = 1.0 / 3.0;
        is_above = 1;
    } else if (house == 12) {
        f = 2.0 / 3.0;
        is_above = 1;
    } else if (house == 2) {
        f = 2.0 / 3.0;
        is_above = 0;
    } else if (house == 3) {
        f = 1.0 / 3.0;
        is_above = 0;
    } else {
        return 0.0;
    }

    double ra = (armc_deg + (is_above ? 90.0 * f : (180.0 - 90.0 * (1.0 - f)))) * DEG2RAD;
    
    for (int iter = 0; iter < 25; iter++) {
        double tan_delta = tan(eps) * sin(ra);
        double delta = atan(tan_delta);
        
        double sin_ad = tan(phi) * tan(delta);
        if (sin_ad > 0.9999) sin_ad = 0.9999;
        if (sin_ad < -0.9999) sin_ad = -0.9999;
        double ad = asin(sin_ad);
        
        double new_ra;
        if (is_above) {
            new_ra = (armc_deg + 90.0 * f) * DEG2RAD + ad * f;
        } else {
            new_ra = (armc_deg + 180.0 - 90.0 * (1.0 - f)) * DEG2RAD + ad * (1.0 - f);
        }
        
        if (fabs(new_ra - ra) < 1e-7) {
            ra = new_ra;
            break;
        }
        ra = new_ra;
    }
    
    double sin_ra = sin(ra);
    double cos_ra = cos(ra);
    double sin_dec = sin(eps) * sin_ra;
    double cos_dec = cos(asin(sin_dec));
    double num = sin_ra * cos(eps) + (sin_dec / cos_dec) * sin(eps);
    double den = cos_ra;
    double lon = atan2(num, den) * RAD2DEG;
    return norm360(lon);
}

int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <YYYY-MM-DD> <HH:MM:SS> <latitude> <longitude> [ayanamsha]\n", argv[0]);
        return 1;
    }

    int year, month, day, hour, min;
    double sec;
    if (sscanf(argv[1], "%d-%d-%d", &year, &month, &day) != 3) {
        fprintf(stderr, "Invalid date format. Expected YYYY-MM-DD\n");
        return 1;
    }
    if (sscanf(argv[2], "%d:%d:%lf", &hour, &min, &sec) < 2) {
        fprintf(stderr, "Invalid time format. Expected HH:MM:SS\n");
        return 1;
    }

    double lat = atof(argv[3]);
    double lng = atof(argv[4]);
    const char *ayanamsha_type = (argc >= 6) ? argv[5] : "lahiri";

    // Build UTC Astronomy Engine time
    astro_time_t time = Astronomy_MakeTime(year, month, day, hour, min, sec);
    double jd = time.ut + 2451545.0; // Julian Date

    // Calculate Ayanamsha
    double ayanamsha = compute_lahiri_ayanamsha(jd);
    const char *ayanamsha_name = "Lahiri";
    if (strcasecmp(ayanamsha_type, "kp") == 0) {
        ayanamsha -= (5.0 / 60.0 + 52.0 / 3600.0); // KP offset
        ayanamsha_name = "KP";
    }

    // Sidereal time & Obliquity
    double gast_hours = Astronomy_SiderealTime(&time);
    double gast_deg = gast_hours * 15.0;
    double armc = norm360(gast_deg + lng);
    
    double eps = compute_obliquity(jd);
    double eps_rad = eps * DEG2RAD;
    double phi_rad = lat * DEG2RAD;
    double armc_rad = armc * DEG2RAD;

    // Ascendant (Lagna)
    double y_asc = cos(armc_rad);
    double x_asc = -sin(armc_rad) * cos(eps_rad) - tan(phi_rad) * sin(eps_rad);
    double asc_sayana = norm360(atan2(y_asc, x_asc) * RAD2DEG);
    double ascendant_sidereal = norm360(asc_sayana - ayanamsha);

    // Midheaven (MC)
    double y_mc = sin(armc_rad);
    double x_mc = cos(armc_rad) * cos(eps_rad);
    double mc_sayana = norm360(atan2(y_mc, x_mc) * RAD2DEG);
    double mc_sidereal = norm360(mc_sayana - ayanamsha);

    // House cusps (Placidus)
    double houses_sidereal[13];
    houses_sidereal[10] = mc_sidereal;
    houses_sidereal[1]  = ascendant_sidereal;
    houses_sidereal[11] = norm360(calc_placidus_cusp(11, armc, lat, eps) - ayanamsha);
    houses_sidereal[12] = norm360(calc_placidus_cusp(12, armc, lat, eps) - ayanamsha);
    houses_sidereal[2]  = norm360(calc_placidus_cusp(3, armc, lat, eps) - ayanamsha); // H2
    houses_sidereal[3]  = norm360(calc_placidus_cusp(2, armc, lat, eps) - ayanamsha); // H3
    
    // Opposites
    houses_sidereal[4]  = norm360(houses_sidereal[10] + 180.0);
    houses_sidereal[5]  = norm360(houses_sidereal[11] + 180.0);
    houses_sidereal[6]  = norm360(houses_sidereal[12] + 180.0);
    houses_sidereal[7]  = norm360(houses_sidereal[1]  + 180.0);
    houses_sidereal[8]  = norm360(houses_sidereal[2]  + 180.0);
    houses_sidereal[9]  = norm360(houses_sidereal[3]  + 180.0);

    // Calculate Planets
    struct PlanetDef {
        const char *id;
        astro_body_t body;
    };

    struct PlanetDef planet_defs[] = {
        {"sun",     BODY_SUN},
        {"moon",    BODY_MOON},
        {"mercury", BODY_MERCURY},
        {"venus",   BODY_VENUS},
        {"mars",    BODY_MARS},
        {"jupiter", BODY_JUPITER},
        {"saturn",  BODY_SATURN},
        {"uranus",  BODY_URANUS},
        {"neptune", BODY_NEPTUNE},
        {"pluto",   BODY_PLUTO},
    };
    int num_planets = sizeof(planet_defs) / sizeof(planet_defs[0]);

    // Small time delta for numerical derivative (speed)
    const double dt_days = 0.01; // ~14.4 mins
    astro_time_t time2 = Astronomy_AddDays(time, dt_days);

    // JSON Output
    printf("{\n");
    printf("  \"success\": true,\n");
    printf("  \"ayanamsha\": %.6f,\n", ayanamsha);
    printf("  \"ayanamsha_name\": \"%s\",\n", ayanamsha_name);
    printf("  \"ascendant\": %.6f,\n", ascendant_sidereal);
    printf("  \"mc\": %.6f,\n", mc_sidereal);
    
    // Houses JSON
    printf("  \"houses\": {\n");
    for (int h = 1; h <= 12; h++) {
        printf("    \"%d\": %.6f%s\n", h, houses_sidereal[h], (h < 12) ? "," : "");
    }
    printf("  },\n");

    // Planets JSON
    printf("  \"planets\": {\n");
    for (int i = 0; i < num_planets; i++) {
        double lon1 = get_body_ecliptic_lon(planet_defs[i].body, time);
        double lon2 = get_body_ecliptic_lon(planet_defs[i].body, time2);
        double diff = lon2 - lon1;
        if (diff > 180.0) diff -= 360.0;
        if (diff < -180.0) diff += 360.0;
        double speed = diff / dt_days; // degrees/day
        double sidereal_lon = norm360(lon1 - ayanamsha);
        int retrograde = (speed < 0.0);

        printf("    \"%s\": {\"longitude\": %.6f, \"speed\": %.6f, \"retrograde\": %s},\n",
               planet_defs[i].id, sidereal_lon, speed, retrograde ? "true" : "false");
    }

    // Rahu & Ketu
    double rahu_sayana1 = compute_true_rahu(jd);
    double rahu_sayana2 = compute_true_rahu(jd + dt_days);
    double r_diff = rahu_sayana2 - rahu_sayana1;
    if (r_diff > 180.0) r_diff -= 360.0;
    if (r_diff < -180.0) r_diff += 360.0;
    double rahu_speed = r_diff / dt_days;
    double rahu_sidereal = norm360(rahu_sayana1 - ayanamsha);
    double ketu_sidereal = norm360(rahu_sidereal + 180.0);

    printf("    \"rahu\": {\"longitude\": %.6f, \"speed\": %.6f, \"retrograde\": true},\n",
           rahu_sidereal, rahu_speed);
    printf("    \"ketu\": {\"longitude\": %.6f, \"speed\": %.6f, \"retrograde\": true}\n",
           ketu_sidereal, rahu_speed);
           
    printf("  }\n");
    printf("}\n");

    return 0;
}
