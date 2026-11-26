<?php

namespace App\Services\Astrology;

class ChalitCalculator
{
    /**
     * Assign planets to houses based on cusp boundaries.
     *
     * @param  array<string, array{longitude: float}>  $planets  [planetId => ['longitude' => float]]
     * @param  array<int, float>  $houseCusps  [1 => float, 2 => float, ... 12 => float]
     * @return array<string, int> [planetId => houseNumber (1-12)]
     */
    public function assignPlanetsToHouses(array $planets, array $houseCusps): array
    {
        $assignments = [];

        foreach ($planets as $id => $data) {
            $lng = fmod(fmod($data['longitude'], 360) + 360, 360);
            $assignments[$id] = $this->findHouseForLongitude($lng, $houseCusps);
        }

        return $assignments;
    }

    /**
     * Determine which house a given longitude falls into based on cusps.
     *
     * @param  float  $longitude  Planet's sidereal longitude
     * @param  array<int, float>  $houseCusps  Cusp longitudes for houses 1-12
     * @return int House number (1-12)
     */
    private function findHouseForLongitude(float $longitude, array $houseCusps): int
    {
        for ($i = 1; $i <= 12; $i++) {
            $nextHouse = ($i % 12) + 1;
            $cuspStart = $houseCusps[$i];
            $cuspEnd = $houseCusps[$nextHouse];

            // Handle wrap-around at 360°
            if ($cuspEnd < $cuspStart) {
                if ($longitude >= $cuspStart || $longitude < $cuspEnd) {
                    return $i;
                }
            } else {
                if ($longitude >= $cuspStart && $longitude < $cuspEnd) {
                    return $i;
                }
            }
        }

        return 1;
    }

    /**
     * Build the Chalit chart house-planet mapping.
     *
     * @param  array<string, array{longitude: float}>  $planets
     * @param  array<int, float>  $houseCusps
     * @return array<int, array<int, string>> [houseNumber => [planetId, ...]]
     */
    public function buildChalitChart(array $planets, array $houseCusps): array
    {
        $chart = [];
        for ($i = 1; $i <= 12; $i++) {
            $chart[$i] = [];
        }

        $assignments = $this->assignPlanetsToHouses($planets, $houseCusps);

        foreach ($assignments as $planetId => $house) {
            $chart[$house][] = $planetId;
        }

        return $chart;
    }
}
