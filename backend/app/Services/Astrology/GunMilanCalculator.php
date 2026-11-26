<?php

namespace App\Services\Astrology;

class GunMilanCalculator
{
    private const VARNA_RANK = [
        'शूद्र' => 0,
        'वैश्य' => 1,
        'क्षत्रिय' => 2,
        'ब्राह्मण' => 3,
    ];

    private const VASHYA_TYPES = ['नर', 'चतुष्पद', 'जलचर', 'वनचर', 'कीट'];

    private const VASHYA_MATRIX = [
        /* नर */ [2,   1,      1,    0.5,   0],
        /* चतुष्पद */ [1,   2,      0,    1,     0],
        /* जलचर */ [1,   0,      2,    0,     0],
        /* वनचर */ [0.5, 1,      0,    2,     0],
        /* कीट */ [0,   0,      0,    0,     2],
    ];

    private const YONI_ANIMALS = [
        'अश्व', 'गज', 'मेष', 'सर्प', 'श्वान', 'मार्जार',
        'मूषक', 'गौ', 'महिष', 'व्याघ्र', 'मृग', 'वानर',
        'नकुल', 'सिंह',
    ];

    private const YONI_MATRIX = [
        [4, 2, 2, 3, 2, 2, 2, 2, 2, 1, 1, 3, 2, 2],   // अश्व
        [2, 4, 3, 3, 2, 2, 2, 2, 2, 1, 3, 2, 2, 0],   // गज
        [2, 3, 4, 2, 2, 2, 2, 1, 2, 1, 2, 3, 2, 2],   // मेष
        [3, 3, 2, 4, 2, 1, 0, 2, 2, 2, 2, 2, 0, 2],   // सर्प
        [2, 2, 2, 2, 4, 1, 2, 2, 2, 2, 1, 2, 2, 2],   // श्वान
        [2, 2, 2, 1, 1, 4, 0, 2, 2, 2, 2, 2, 2, 2],   // मार्जार
        [2, 2, 2, 0, 2, 0, 4, 2, 2, 2, 2, 2, 1, 2],   // मूषक
        [2, 2, 1, 2, 2, 2, 2, 4, 3, 0, 2, 2, 2, 1],   // गौ
        [2, 2, 2, 2, 2, 2, 2, 3, 4, 1, 2, 2, 2, 2],   // महिष
        [1, 1, 1, 2, 2, 2, 2, 0, 1, 4, 1, 2, 2, 0],   // व्याघ्र
        [1, 3, 2, 2, 1, 2, 2, 2, 2, 1, 4, 3, 2, 2],   // मृग
        [3, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 4, 2, 2],   // वानर
        [2, 2, 2, 0, 2, 2, 1, 2, 2, 2, 2, 2, 4, 2],   // नकुल
        [2, 0, 2, 2, 2, 2, 2, 1, 2, 0, 2, 2, 2, 4],   // सिंह
    ];

    private const GRAHA_MAITRI = [
        'Sun' => ['Sun' => 'F', 'Moon' => 'F', 'Mars' => 'F', 'Mercury' => 'E', 'Jupiter' => 'F', 'Venus' => 'E', 'Saturn' => 'E'],
        'Moon' => ['Sun' => 'F', 'Moon' => 'F', 'Mars' => 'N', 'Mercury' => 'F', 'Jupiter' => 'N', 'Venus' => 'N', 'Saturn' => 'N'],
        'Mars' => ['Sun' => 'F', 'Moon' => 'F', 'Mars' => 'F', 'Mercury' => 'E', 'Jupiter' => 'F', 'Venus' => 'N', 'Saturn' => 'E'],
        'Mercury' => ['Sun' => 'F', 'Moon' => 'E', 'Mars' => 'N', 'Mercury' => 'F', 'Jupiter' => 'N', 'Venus' => 'F', 'Saturn' => 'N'],
        'Jupiter' => ['Sun' => 'F', 'Moon' => 'F', 'Mars' => 'F', 'Mercury' => 'E', 'Jupiter' => 'F', 'Venus' => 'E', 'Saturn' => 'N'],
        'Venus' => ['Sun' => 'E', 'Moon' => 'N', 'Mars' => 'N', 'Mercury' => 'F', 'Jupiter' => 'N', 'Venus' => 'F', 'Saturn' => 'F'],
        'Saturn' => ['Sun' => 'E', 'Moon' => 'E', 'Mars' => 'E', 'Mercury' => 'F', 'Jupiter' => 'N', 'Venus' => 'F', 'Saturn' => 'F'],
    ];

    private const GANA_TYPES = ['देव', 'मनुष्य', 'राक्षस'];

    private const GANA_MATRIX = [
        /* देव */ [6,   5,      1],
        /* मनुष्य */ [5,   6,      0],
        /* राक्षस */ [0,   0,      6],
    ];

    private const BHAKUT_DOSHA_PAIRS = [
        [2, 12],
        [5, 9],
        [6, 8],
    ];

    /**
     * Calculate complete Ashtakoot Gun Milan.
     *
     * @param  int  $boyMoonRashiIndex  Boy's Moon Rashi index (0-11)
     * @param  int  $boyNakshatraIndex  Boy's Moon Nakshatra index (0-26)
     * @param  int  $girlMoonRashiIndex  Girl's Moon Rashi index (0-11)
     * @param  int  $girlNakshatraIndex  Girl's Moon Nakshatra index (0-26)
     * @param  array<string, mixed>  $mangalDetails
     * @return array<string, mixed> Complete Gun Milan result
     */
    public function calculate(
        int $boyMoonRashiIndex,
        int $boyNakshatraIndex,
        int $girlMoonRashiIndex,
        int $girlNakshatraIndex,
        bool $boyMangal = false,
        bool $girlMangal = false,
        array $mangalDetails = []
    ): array {
        $boyRashi = AstrologyData::RASHI[$boyMoonRashiIndex];
        $girlRashi = AstrologyData::RASHI[$girlMoonRashiIndex];
        $boyNakshatra = AstrologyData::NAKSHATRA[$boyNakshatraIndex];
        $girlNakshatra = AstrologyData::NAKSHATRA[$girlNakshatraIndex];

        // Calculate each guna
        $gunas = [];
        $gunas[] = $this->calculateVarna($boyRashi, $girlRashi);
        $gunas[] = $this->calculateVashya($boyRashi, $girlRashi);
        $gunas[] = $this->calculateTara($boyNakshatraIndex, $girlNakshatraIndex);
        $gunas[] = $this->calculateYoni($boyNakshatra, $girlNakshatra);
        $gunas[] = $this->calculateGrahaMaitri($boyRashi, $girlRashi);
        $gunas[] = $this->calculateGana($boyNakshatra, $girlNakshatra);
        $gunas[] = $this->calculateBhakut($boyMoonRashiIndex, $girlMoonRashiIndex);
        $gunas[] = $this->calculateNadi($boyNakshatra, $girlNakshatra);
        $gunas[] = $this->calculateNakshatraRow($boyNakshatra, $girlNakshatra);

        $scoringGunas = array_filter($gunas, fn ($g) => isset($g['max_points']) && is_numeric($g['max_points']));
        $totalObtained = array_sum(array_column($scoringGunas, 'obtained'));
        $totalMax = 36;
        $percentage = round(($totalObtained / $totalMax) * 100, 1);

        return [
            'gunas' => $gunas,
            'total_max' => $totalMax,
            'total_obtained' => $totalObtained,
            'percentage' => $percentage,
            'conclusion' => $this->getConclusion($totalObtained, $boyMangal, $girlMangal, $mangalDetails),
            'mangal_dosha' => [
                'boy' => $boyMangal,
                'girl' => $girlMangal,
                'details' => $mangalDetails,
            ],
        ];
    }

    private function calculateVarna(array $boyRashi, array $girlRashi): array
    {
        $boyVarna = $boyRashi['varna'];
        $girlVarna = $girlRashi['varna'];

        $boyRank = self::VARNA_RANK[$boyVarna] ?? 0;
        $girlRank = self::VARNA_RANK[$girlVarna] ?? 0;

        $points = ($boyRank >= $girlRank) ? 1 : 0;

        return [
            'name' => 'वर्ण',
            'name_en' => 'Varna',
            'description' => 'जातीय सुसंगतता (Social compatibility)',
            'boy_value' => $boyVarna,
            'girl_value' => $girlVarna,
            'max_points' => 1,
            'obtained' => $points,
        ];
    }

    private function calculateVashya(array $boyRashi, array $girlRashi): array
    {
        $boyVashya = $boyRashi['vashya'];
        $girlVashya = $girlRashi['vashya'];

        $boyIdx = array_search($boyVashya, self::VASHYA_TYPES, true);
        $girlIdx = array_search($girlVashya, self::VASHYA_TYPES, true);

        $points = 0;
        if ($boyIdx !== false && $girlIdx !== false) {
            $points = self::VASHYA_MATRIX[$boyIdx][$girlIdx];
        }

        return [
            'name' => 'वश्य',
            'name_en' => 'Vashya',
            'description' => 'आकर्षण व वर्चस्व (Dominance & attraction)',
            'boy_value' => $boyVashya,
            'girl_value' => $girlVashya,
            'max_points' => 2,
            'obtained' => $points,
        ];
    }

    private function calculateTara(int $boyNakIdx, int $girlNakIdx): array
    {
        $girlToBoy = (($boyNakIdx - $girlNakIdx + 27) % 27) + 1;
        $remainder1 = $girlToBoy % 9;
        if ($remainder1 === 0) {
            $remainder1 = 9;
        }
        $girlToBoyAuspicious = ! in_array($remainder1, [3, 5, 7], true);

        $boyToGirl = (($girlNakIdx - $boyNakIdx + 27) % 27) + 1;
        $remainder2 = $boyToGirl % 9;
        if ($remainder2 === 0) {
            $remainder2 = 9;
        }
        $boyToGirlAuspicious = ! in_array($remainder2, [3, 5, 7], true);

        if ($girlToBoyAuspicious && $boyToGirlAuspicious) {
            $points = 3;
        } elseif ($girlToBoyAuspicious || $boyToGirlAuspicious) {
            $points = 1.5;
        } else {
            $points = 0;
        }

        $boyNakName = AstrologyData::NAKSHATRA[$boyNakIdx]['name'];
        $girlNakName = AstrologyData::NAKSHATRA[$girlNakIdx]['name'];

        return [
            'name' => 'तारा',
            'name_en' => 'Tara',
            'description' => 'नक्षत्र सुसंगतता (Birth star compatibility)',
            'boy_value' => $boyNakName,
            'girl_value' => $girlNakName,
            'max_points' => 3,
            'obtained' => $points,
        ];
    }

    private function calculateYoni(array $boyNakshatra, array $girlNakshatra): array
    {
        $boyYoni = $boyNakshatra['yoni'];
        $girlYoni = $girlNakshatra['yoni'];

        $boyIdx = array_search($boyYoni, self::YONI_ANIMALS, true);
        $girlIdx = array_search($girlYoni, self::YONI_ANIMALS, true);

        $points = 0;
        if ($boyIdx !== false && $girlIdx !== false) {
            $points = self::YONI_MATRIX[$boyIdx][$girlIdx];
        }

        return [
            'name' => 'योनि',
            'name_en' => 'Yoni',
            'description' => 'शारीरिक सुसंगतता (Physical/sexual compatibility)',
            'boy_value' => $boyYoni,
            'girl_value' => $girlYoni,
            'max_points' => 4,
            'obtained' => $points,
        ];
    }

    private function calculateGrahaMaitri(array $boyRashi, array $girlRashi): array
    {
        $boyLord = $boyRashi['lord'];
        $girlLord = $girlRashi['lord'];

        $boyToGirl = self::GRAHA_MAITRI[$boyLord][$girlLord] ?? 'N';
        $girlToBoy = self::GRAHA_MAITRI[$girlLord][$boyLord] ?? 'N';

        $pair = $this->sortPair($boyToGirl, $girlToBoy);
        $points = match ($pair) {
            'FF' => 5,
            'FN' => 4,
            'NN' => 3,
            'FE' => 1,
            'NE' => 0.5,
            'EE' => 0,
            default => 0,
        };

        $lordNames = [
            'Sun' => 'सूर्य', 'Moon' => 'चंद्र', 'Mars' => 'मंगळ',
            'Mercury' => 'बुध', 'Jupiter' => 'गुरु', 'Venus' => 'शुक्र', 'Saturn' => 'शनि',
        ];

        return [
            'name' => 'ग्रह मैत्री',
            'name_en' => 'Graha Maitri',
            'description' => 'मानसिक सुसंगतता (Mental/intellectual compatibility)',
            'boy_value' => $lordNames[$boyLord] ?? $boyLord,
            'girl_value' => $lordNames[$girlLord] ?? $girlLord,
            'max_points' => 5,
            'obtained' => $points,
        ];
    }

    private function sortPair(string $a, string $b): string
    {
        $order = ['F' => 0, 'N' => 1, 'E' => 2];
        if (($order[$a] ?? 9) <= ($order[$b] ?? 9)) {
            return $a.$b;
        }

        return $b.$a;
    }

    private function calculateGana(array $boyNakshatra, array $girlNakshatra): array
    {
        $boyGana = $boyNakshatra['gana'];
        $girlGana = $girlNakshatra['gana'];

        $boyIdx = array_search($boyGana, self::GANA_TYPES, true);
        $girlIdx = array_search($girlGana, self::GANA_TYPES, true);

        $points = 0;
        if ($boyIdx !== false && $girlIdx !== false) {
            $points = self::GANA_MATRIX[$boyIdx][$girlIdx];
        }

        return [
            'name' => 'गण',
            'name_en' => 'Gana',
            'description' => 'स्वभाव सुसंगतता (Temperament compatibility)',
            'boy_value' => $boyGana,
            'girl_value' => $girlGana,
            'max_points' => 6,
            'obtained' => $points,
        ];
    }

    private function calculateBhakut(int $boyRashiIdx, int $girlRashiIdx): array
    {
        $boyRashi = AstrologyData::RASHI[$boyRashiIdx];
        $girlRashi = AstrologyData::RASHI[$girlRashiIdx];

        $boyToGirl = (($girlRashiIdx - $boyRashiIdx + 12) % 12) + 1;
        $girlToBoy = (($boyRashiIdx - $girlRashiIdx + 12) % 12) + 1;

        $hasBhakutDosha = false;
        foreach (self::BHAKUT_DOSHA_PAIRS as [$pos1, $pos2]) {
            if (($boyToGirl === $pos1 && $girlToBoy === $pos2) ||
                ($boyToGirl === $pos2 && $girlToBoy === $pos1)) {
                $hasBhakutDosha = true;
                break;
            }
        }

        $points = 7;

        if ($hasBhakutDosha) {
            if ($boyRashi['lord'] === $girlRashi['lord']) {
                $points = 7;
            } else {
                $points = 0;
            }
        }

        return [
            'name' => 'भकूट',
            'name_en' => 'Bhakut',
            'description' => 'प्रेम व कुटुंब सुसंगतता (Love & family compatibility)',
            'boy_value' => $boyRashi['name'],
            'girl_value' => $girlRashi['name'],
            'max_points' => 7,
            'obtained' => $points,
            'note' => true,
        ];
    }

    private function calculateNadi(array $boyNakshatra, array $girlNakshatra): array
    {
        $boyNadi = $boyNakshatra['nadi'];
        $girlNadi = $girlNakshatra['nadi'];

        $nadiMap = [
            'आदि' => 'आद्य',
            'आद्य' => 'आद्य',
            'मध्य' => 'मध्य',
            'अंत्य' => 'अंत्य',
        ];

        $boyDisplay = $nadiMap[$boyNadi] ?? $boyNadi;
        $girlDisplay = $nadiMap[$girlNadi] ?? $girlNadi;

        $points = ($boyDisplay === $girlDisplay) ? 0 : 8;

        return [
            'name' => 'नाडी',
            'name_en' => 'Nadi',
            'description' => 'आरोग्य व वंश सुसंगतता (Health & progeny compatibility)',
            'boy_value' => $boyDisplay,
            'girl_value' => $girlDisplay,
            'max_points' => 8,
            'obtained' => $points,
            'nadi_dosha' => ($boyDisplay === $girlDisplay),
        ];
    }

    private function calculateNakshatraRow(array $boyNakshatra, array $girlNakshatra): array
    {
        return [
            'name' => 'नक्षत्र',
            'name_en' => 'Nakshatra',
            'description' => 'जन्म नक्षत्र (Birth star)',
            'boy_value' => $boyNakshatra['name'],
            'girl_value' => $girlNakshatra['name'],
            'max_points' => '-',
            'obtained' => '-',
        ];
    }

    private function getConclusion(
        float $totalObtained,
        bool $boyMangal = false,
        bool $girlMangal = false,
        array $mangalDetails = []
    ): string {
        $mangalText = '';
        if (! empty($mangalDetails['summary'])) {
            $mangalText = $mangalDetails['summary'];
        } elseif (! $boyMangal && ! $girlMangal) {
            $mangalText = 'युवक आणि युवतीच्या भाव चलित कुंडलीमध्ये 1, 4, 7, 8, आणि 12 व्या स्थानी मंगळ न असल्याने मंगळ दोष मानला जात नाही.';
        } elseif ($boyMangal && $girlMangal) {
            $mangalText = 'दोन्ही कुंडलीमध्ये (भाव चलितनुसार) मंगळ दोष असल्याने मंगळ दोष रद्द (साम्य) मानला जातो.';
        } elseif ($boyMangal) {
            $mangalText = 'युवकाच्या भाव चलित कुंडलीमध्ये मंगळ दोष आहे (1, 4, 7, 8, किंवा 12 व्या स्थानी मंगळ आहे).';
        } else {
            $mangalText = 'युवतीच्या भाव चलित कुंडलीमध्ये मंगळ दोष आहे (1, 4, 7, 8, किंवा 12 व्या स्थानी मंगळ आहे).';
        }

        $formattedScore = number_format($totalObtained, 2);

        if ($totalObtained >= 18) {
            $suitability = "आपले गुण {$formattedScore} आहेत म्हणून हे गुण मिलन वैवाहिक जीवना करीता योग्य आहे.";
        } else {
            $suitability = "आपले गुण {$formattedScore} आहेत म्हणून हे गुण मिलन वैवाहिक जीवना करीता योग्य नाही.";
        }

        return $mangalText.' '.$suitability;
    }
}
