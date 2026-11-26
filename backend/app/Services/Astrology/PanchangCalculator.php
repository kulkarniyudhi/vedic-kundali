<?php

namespace App\Services\Astrology;

class PanchangCalculator
{
    /**
     * Calculate all Panchang elements.
     *
     * @param  float  $sunLongitude  Sidereal longitude of Sun (degrees)
     * @param  float  $moonLongitude  Sidereal longitude of Moon (degrees)
     * @return array<string, mixed> Complete Panchang data
     */
    public function calculate(float $sunLongitude, float $moonLongitude): array
    {
        return [
            'tithi' => $this->calculateTithi($sunLongitude, $moonLongitude),
            'nakshatra' => $this->calculateNakshatra($moonLongitude),
            'yoga' => $this->calculateYoga($sunLongitude, $moonLongitude),
            'karana' => $this->calculateKarana($sunLongitude, $moonLongitude),
            'rashi' => $this->calculateMoonRashi($moonLongitude),
        ];
    }

    /**
     * Calculate Tithi (Lunar Day).
     *
     * @return array{index: int, number: int, name: string, paksha: string, display: string}
     */
    public function calculateTithi(float $sunLng, float $moonLng): array
    {
        $diff = fmod(($moonLng - $sunLng) + 360, 360);
        $tithiIndex = (int) floor($diff / 12); // 0-29

        $paksha = ($tithiIndex < 15) ? 'शुक्ल' : 'कृष्ण';
        $tithiNumber = ($tithiIndex % 15) + 1;
        $tithiName = AstrologyData::TITHI[$tithiIndex];

        return [
            'index' => $tithiIndex,
            'number' => $tithiNumber,
            'name' => $tithiName,
            'paksha' => $paksha,
            'display' => $paksha.' - '.$tithiNumber,
        ];
    }

    /**
     * Calculate Nakshatra (Lunar Mansion).
     *
     * @return array{index: int, number: int, name: string, name_short: string, pada: int, lord: string, syllable: string, display: string}
     */
    public function calculateNakshatra(float $moonLng): array
    {
        $nakshatraIndex = AstrologyData::getNakshatraIndex($moonLng);
        $pada = AstrologyData::getNakshatraPada($moonLng);
        $nakshatraData = AstrologyData::NAKSHATRA[$nakshatraIndex];
        $syllable = AstrologyData::getNakshatraSyllable($nakshatraIndex, $pada);

        return [
            'index' => $nakshatraIndex,
            'number' => $nakshatraIndex + 1,
            'name' => $nakshatraData['name'],
            'name_short' => $nakshatraData['name_short'],
            'pada' => $pada,
            'lord' => $nakshatraData['lord'],
            'syllable' => $syllable,
            'display' => $nakshatraData['name_short'].' -'.$pada.' ( '.$syllable.' )',
        ];
    }

    /**
     * Calculate Yoga (Luni-Solar Combination).
     *
     * @return array{index: int, number: int, name: string}
     */
    public function calculateYoga(float $sunLng, float $moonLng): array
    {
        $sum = fmod(($sunLng + $moonLng), 360);
        if ($sum < 0) {
            $sum += 360;
        }
        $yogaIndex = (int) floor($sum / (360 / 27)); // 0-26

        return [
            'index' => $yogaIndex,
            'number' => $yogaIndex + 1,
            'name' => AstrologyData::YOGA[$yogaIndex],
        ];
    }

    /**
     * Calculate Karana (Half-Tithi).
     *
     * @return array{index: int, name: string}
     */
    public function calculateKarana(float $sunLng, float $moonLng): array
    {
        $diff = fmod(($moonLng - $sunLng) + 360, 360);
        $karanaIndex = (int) floor($diff / 6); // 0-59

        return [
            'index' => $karanaIndex,
            'name' => AstrologyData::getKaranaName($karanaIndex),
        ];
    }

    /**
     * Calculate Moon Rashi (Moon Sign).
     *
     * @return array{index: int, number: int, name: string, name_en: string, lord: string, syllables: string, display: string}
     */
    public function calculateMoonRashi(float $moonLng): array
    {
        $rashiIndex = AstrologyData::getRashiIndex($moonLng);
        $rashiData = AstrologyData::RASHI[$rashiIndex];
        $syllables = AstrologyData::RASHI_SYLLABLES[$rashiIndex];

        return [
            'index' => $rashiIndex,
            'number' => $rashiIndex + 1,
            'name' => $rashiData['name'],
            'name_en' => $rashiData['name_en'],
            'lord' => $rashiData['lord'],
            'syllables' => $syllables,
            'display' => $rashiData['name'].' ( '.$syllables.' )',
        ];
    }
}
