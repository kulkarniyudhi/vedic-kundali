<?php

namespace App\Services\Astrology;

use DateTime;

class MahadashaCalculator
{
    /**
     * Calculate Vimshottari Mahadasha periods.
     *
     * @param  float  $moonLongitude  Sidereal Moon longitude at birth
     * @param  DateTime  $birthDate  Date/time of birth (local timezone)
     * @return array<int, array{planet_key: string, planet_name: string, total_years: int, actual_years: float, start_date: string, end_date: string}>
     */
    public function calculate(float $moonLongitude, DateTime $birthDate): array
    {
        $nakshatraIndex = AstrologyData::getNakshatraIndex($moonLongitude);
        $dashaLord = AstrologyData::NAKSHATRA_DASHA_LORD[$nakshatraIndex];

        // Calculate balance of first Dasha
        $nakshatraSpan = 360.0 / 27.0; // 13.3333...°
        $posInNakshatra = fmod(fmod($moonLongitude, 360) + 360, 360) - ($nakshatraIndex * $nakshatraSpan);
        $elapsed = $posInNakshatra / $nakshatraSpan;
        $remaining = 1.0 - $elapsed;

        // Find the starting lord in the Dasha sequence
        $dashaSequence = AstrologyData::DASHA_SEQUENCE;
        $startIndex = array_search($dashaLord, $dashaSequence, true);
        if ($startIndex === false) {
            $startIndex = 0;
        }

        // Build Mahadasha periods
        $periods = [];
        $currentDate = clone $birthDate;

        for ($i = 0; $i < 9; $i++) {
            $seqIndex = ($startIndex + $i) % 9;
            $planetKey = $dashaSequence[$seqIndex];
            $planetData = AstrologyData::PLANETS[$planetKey];
            $totalYears = $planetData['dasha_years'];

            // First period uses the remaining balance, rest use full duration
            $years = ($i === 0) ? ($totalYears * $remaining) : $totalYears;

            // Calculate end date
            $endDate = clone $currentDate;
            $endDate = $this->addYearsDecimal($endDate, $years);

            $periods[] = [
                'planet_key' => $planetKey,
                'planet_name' => $planetData['name'],
                'total_years' => $totalYears,
                'actual_years' => round($years, 4),
                'start_date' => $currentDate->format('d/m/Y'),
                'end_date' => $endDate->format('d/m/Y'),
            ];

            $currentDate = clone $endDate;
        }

        return $periods;
    }

    /**
     * Add a decimal number of years to a DateTime.
     */
    private function addYearsDecimal(DateTime $date, float $years): DateTime
    {
        $totalDays = (int) round($years * 365.25);
        $date->modify("+{$totalDays} days");

        return $date;
    }
}
