<?php

namespace App\Services\Astrology;

class KundaliChart
{
    /**
     * Build Lagna Kundali (Whole Sign system based on Ascendant).
     *
     * @param  array<string, array{longitude: float}>  $planets
     * @param  float  $ascendantLng  Ascendant's sidereal longitude
     * @return array{houses: array<int, array<int, string>>, ascendant_rashi: int, title: string}
     */
    public function getLagnaChart(array $planets, float $ascendantLng): array
    {
        $ascRashi = AstrologyData::getRashiIndex($ascendantLng);

        return [
            'houses' => $this->buildWholeSignChart($planets, $ascRashi),
            'ascendant_rashi' => $ascRashi,
            'title' => 'लग्न कुंडली',
        ];
    }

    /**
     * Build Chandra Rashi Kundali (Whole Sign system based on Moon).
     *
     * @param  array<string, array{longitude: float}>  $planets
     * @param  float  $moonLng  Moon's sidereal longitude
     * @return array{houses: array<int, array<int, string>>, ascendant_rashi: int, title: string}
     */
    public function getChandraChart(array $planets, float $moonLng): array
    {
        $moonRashi = AstrologyData::getRashiIndex($moonLng);

        return [
            'houses' => $this->buildWholeSignChart($planets, $moonRashi),
            'ascendant_rashi' => $moonRashi,
            'title' => 'चंद्र राशी कुंडली',
        ];
    }

    /**
     * Build Navamsha Kundali using pre-computed Navamsha Rashi positions.
     *
     * @param  array<string, int>  $navamshaRashis  [planetId => navamshaRashiIndex]
     * @param  int  $ascNavamshaRashi  Ascendant's Navamsha Rashi index
     * @return array{houses: array<int, array<int, string>>, ascendant_rashi: int, title: string}
     */
    public function getNavamshaChart(array $navamshaRashis, int $ascNavamshaRashi): array
    {
        $chart = [];
        for ($i = 1; $i <= 12; $i++) {
            $chart[$i] = [];
        }

        foreach ($navamshaRashis as $planetId => $navRashi) {
            $house = (($navRashi - $ascNavamshaRashi + 12) % 12) + 1;
            $chart[$house][] = $planetId;
        }

        return [
            'houses' => $chart,
            'ascendant_rashi' => $ascNavamshaRashi,
            'title' => 'नवमांश कुंडली',
        ];
    }

    /**
     * Build Chalit Kundali (cusp-based house assignments).
     *
     * @param  array<int, array<int, string>>  $chalitAssignments
     * @param  int  $ascRashi  Ascendant's Rashi index
     * @return array{houses: array<int, array<int, string>>, ascendant_rashi: int, title: string}
     */
    public function getChalitChart(array $chalitAssignments, int $ascRashi): array
    {
        return [
            'houses' => $chalitAssignments,
            'ascendant_rashi' => $ascRashi,
            'title' => 'चलित कुंडली',
        ];
    }

    /**
     * Build a Whole Sign chart where a given Rashi is House 1.
     *
     * @param  array<string, array{longitude: float}>  $planets
     * @param  int  $house1Rashi  Rashi index for House 1 (0-11)
     * @return array<int, array<int, string>>
     */
    private function buildWholeSignChart(array $planets, int $house1Rashi): array
    {
        $chart = [];
        for ($i = 1; $i <= 12; $i++) {
            $chart[$i] = [];
        }

        foreach ($planets as $planetId => $data) {
            $planetRashi = AstrologyData::getRashiIndex($data['longitude']);
            $house = (($planetRashi - $house1Rashi + 12) % 12) + 1;
            $chart[$house][] = $planetId;
        }

        return $chart;
    }
}
