<?php

namespace App\Services\Astrology;

use DateTime;

class HinduCalendar
{
    /**
     * Calculate all Hindu calendar data.
     *
     * @param  DateTime  $localTime  Birth time in local timezone
     * @param  float  $sunLongitude  Sidereal Sun longitude
     * @param  float  $moonLongitude  Sidereal Moon longitude
     * @return array<string, mixed> Hindu calendar data
     */
    public function calculate(DateTime $localTime, float $sunLongitude, float $moonLongitude): array
    {
        $dayOfWeek = (int) $localTime->format('w'); // 0=Sunday
        $year = (int) $localTime->format('Y');
        $month = (int) $localTime->format('n');

        // Hindu month derived from Sun's Rashi
        $sunRashi = AstrologyData::getRashiIndex($sunLongitude);
        $hinduMonthIndex = $this->getHinduMonthFromSunRashi($sunRashi);

        // Shaka Samvat: Gregorian year - 78
        // If before Chaitra (roughly March), use previous year
        $shakaSamvat = $year - 78;
        if ($month < 3 || ($month === 3 && (int) $localTime->format('j') < 22)) {
            $shakaSamvat = $year - 79;
        }

        // Vikram Samvat (Kartik start): year + 57
        $vikramKartik = $year + 57;
        // Vikram Samvat (Chaitra start): year + 57, adjusted for month
        $vikramChaitra = $year + 57;
        if ($month < 3 || ($month === 3 && (int) $localTime->format('j') < 22)) {
            $vikramChaitra = $year + 56;
        }
        // For Kartik-based: if before Kartik (roughly October), subtract 1
        if ($month < 10) {
            $vikramKartik = $year + 56;
        }

        // Ishtakaala (Ghati-Pal) — approximate calculation
        $ishtaGhati = $this->calculateIshtaGhati($localTime);

        return [
            'day_name' => AstrologyData::DAY_NAMES[$dayOfWeek],
            'day_index' => $dayOfWeek,
            'hindu_month' => AstrologyData::HINDU_MONTHS[$hinduMonthIndex],
            'hindu_month_index' => $hinduMonthIndex,
            'shaka_samvat' => $shakaSamvat,
            'vikram_kartik' => $vikramKartik,
            'vikram_chaitra' => $vikramChaitra,
            'ishta_ghati' => $ishtaGhati,
        ];
    }

    /**
     * Get Hindu month index from Sun's Rashi.
     */
    private function getHinduMonthFromSunRashi(int $sunRashi): int
    {
        $map = [
            0 => 1,  // Mesha → Vaishakh
            1 => 2,  // Vrishabha → Jyeshtha
            2 => 3,  // Mithuna → Ashadh
            3 => 4,  // Karka → Shravan
            4 => 5,  // Simha → Bhadrapad
            5 => 6,  // Kanya → Ashwin
            6 => 7,  // Tula → Kartik
            7 => 8,  // Vrishchik → Margashirsha
            8 => 9,  // Dhanu → Paush
            9 => 10, // Makar → Magh
            10 => 11, // Kumbh → Phalgun
            11 => 0,  // Meena → Chaitra
        ];

        return $map[$sunRashi] ?? 0;
    }

    /**
     * Calculate Ishtakaala (Ghati from sunrise).
     * 1 Ghati = 24 minutes, 1 Pal = 24 seconds
     * Approximate sunrise at 6:00 AM local time.
     *
     * @return array{ghati: int, pal: int, vipal: int, display: string}
     */
    private function calculateIshtaGhati(DateTime $localTime): array
    {
        $sunriseHour = 6;
        $sunriseMinute = 0;

        $birthHour = (int) $localTime->format('G');
        $birthMinute = (int) $localTime->format('i');
        $birthSecond = (int) $localTime->format('s');

        // Total minutes from sunrise
        $totalMinutes = ($birthHour * 60 + $birthMinute + $birthSecond / 60)
                      - ($sunriseHour * 60 + $sunriseMinute);

        if ($totalMinutes < 0) {
            $totalMinutes += 24 * 60; // Past midnight, wrap around
        }

        // Convert to Ghati (1 Ghati = 24 minutes)
        $totalGhati = $totalMinutes / 24;
        $ghati = (int) floor($totalGhati);

        // Remaining fraction to Pal (1 Pal = 24 seconds = 0.4 minutes)
        $remainingMinutes = $totalMinutes - ($ghati * 24);
        $pal = (int) floor($remainingMinutes / 0.4);

        // Remaining to Vipal
        $remainingSeconds = ($remainingMinutes - $pal * 0.4) * 60;
        $vipal = (int) round($remainingSeconds / 0.4);

        return [
            'ghati' => $ghati,
            'pal' => $pal,
            'vipal' => $vipal,
            'display' => sprintf('%02d:%02d:%02d', $ghati, $pal, $vipal),
        ];
    }
}
