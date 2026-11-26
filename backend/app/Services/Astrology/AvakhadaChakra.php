<?php

namespace App\Services\Astrology;

class AvakhadaChakra
{
    /**
     * Calculate all Avakahada Chakra attributes.
     *
     * @param  int  $moonRashiIndex  Moon's Rashi index (0-11)
     * @param  int  $nakshatraIndex  Moon's Nakshatra index (0-26)
     * @return array<string, string> All Avakahada attributes
     */
    public function calculate(int $moonRashiIndex, int $nakshatraIndex): array
    {
        $rashiData = AstrologyData::RASHI[$moonRashiIndex];
        $nakshatraData = AstrologyData::NAKSHATRA[$nakshatraIndex];

        return [
            'varna' => $rashiData['varna'],
            'tattva' => $rashiData['element'],
            'vashya' => $rashiData['vashya'],
            'yoni' => $nakshatraData['yoni'],
            'gana' => $nakshatraData['gana'],
            'nadi' => $nakshatraData['nadi'],
            'varga' => AstrologyData::NAKSHATRA_VARGA[$nakshatraIndex] ?? '',
            'yunja' => AstrologyData::NAKSHATRA_YUNJA[$nakshatraIndex] ?? '',
        ];
    }
}
