<?php

namespace App\Services\Astrology;

class NavamshaCalculator
{
    /**
     * Calculate Navamsha Rashi for all planets.
     *
     * @param  array<string, array{longitude: float}>  $planets  Associative array of planet positions
     * @return array<string, int> [planetId => navamshaRashiIndex (0-11)]
     */
    public function calculateAll(array $planets): array
    {
        $result = [];
        foreach ($planets as $id => $data) {
            $result[$id] = $this->calculateNavamshaRashi($data['longitude']);
        }

        return $result;
    }

    /**
     * Calculate the Navamsha Rashi for a given sidereal longitude.
     *
     * @param  float  $longitude  Sidereal longitude in degrees
     * @return int Navamsha Rashi index (0-11)
     */
    public function calculateNavamshaRashi(float $longitude): int
    {
        $lng = fmod(fmod($longitude, 360) + 360, 360);
        $rashiIndex = (int) floor($lng / 30);
        $degreeInSign = fmod($lng, 30);

        // Navamsha number (0-8): each segment is 3.3333...°
        $navamshaNum = (int) floor($degreeInSign / (30.0 / 9.0));
        $navamshaNum = min($navamshaNum, 8); // Safety cap

        // Determine starting sign based on sign type
        $signType = AstrologyData::RASHI[$rashiIndex]['type'];
        $startSign = match ($signType) {
            'movable' => $rashiIndex,        // Same sign
            'fixed' => ($rashiIndex + 8) % 12, // 9th from sign
            'dual' => ($rashiIndex + 4) % 12, // 5th from sign
            default => $rashiIndex,
        };

        // Final Navamsha Rashi
        return ($startSign + $navamshaNum) % 12;
    }
}
