<?php

namespace App\Services\Astrology;

use InvalidArgumentException;

class GunMilanCalculationService
{
    public function __construct(
        protected KundaliCalculationService $kundaliService,
        protected GunMilanCalculator $gunMilanCalculator
    ) {}

    /**
     * Compute Gun Milan matchmaking between boy and girl.
     *
     * @param array{
     *     boy: array<string, mixed>,
     *     girl: array<string, mixed>,
     *     ayanamsha?: string|null,
     *     engine?: string|null
     * } $input
     * @return array<string, mixed>
     */
    public function calculate(array $input): array
    {
        $boyInput = $input['boy'] ?? null;
        $girlInput = $input['girl'] ?? null;
        $ayanamsha = $input['ayanamsha'] ?? 'lahiri';
        $engine = $input['engine'] ?? 'astronomy';

        if (! $boyInput || ! $girlInput) {
            throw new InvalidArgumentException('Both "boy" and "girl" birth details are required');
        }

        $boyInput['ayanamsha'] = $ayanamsha;
        $boyInput['engine'] = $engine;
        $boyInput['name'] = $boyInput['name'] ?? 'युवक';

        $girlInput['ayanamsha'] = $ayanamsha;
        $girlInput['engine'] = $engine;
        $girlInput['name'] = $girlInput['name'] ?? 'युवती';

        $boyData = $this->kundaliService->calculate($boyInput);
        $girlData = $this->kundaliService->calculate($girlInput);

        // Helper function to find Mars house in chart (1-12)
        $findMarsHouse = function (array $chart): int {
            foreach ($chart['houses'] as $house => $planets) {
                if (in_array('mars', $planets, true)) {
                    return (int) $house;
                }
            }

            return 1;
        };

        $mangalHouses = [1, 4, 7, 8, 12];

        $boyLagnaHouse = $findMarsHouse($boyData['charts']['lagna']);
        $boyChalitHouse = $findMarsHouse($boyData['charts']['chalit']);
        $boyHasMangalLagna = in_array($boyLagnaHouse, $mangalHouses, true);
        $boyHasMangalChalit = in_array($boyChalitHouse, $mangalHouses, true);

        $girlLagnaHouse = $findMarsHouse($girlData['charts']['lagna']);
        $girlChalitHouse = $findMarsHouse($girlData['charts']['chalit']);
        $girlHasMangalLagna = in_array($girlLagnaHouse, $mangalHouses, true);
        $girlHasMangalChalit = in_array($girlChalitHouse, $mangalHouses, true);

        $buildPersonMangalDesc = function (
            string $personLabel,
            int $lagnaHouse,
            int $chalitHouse,
            bool $hasMangalChalit,
            bool $hasMangalLagna
        ): array {
            $labelGenitive = ($personLabel === 'युवक') ? 'युवकाच्या' : 'युवतीच्या';
            if ($hasMangalChalit) {
                $desc = "{$labelGenitive} भाव चलित कुंडलीनुसार मंगळ {$chalitHouse} व्या भावात असल्याने मंगळ दोष आहे.";
                if ($lagnaHouse !== $chalitHouse) {
                    $desc .= " (लग्न कुंडलीनुसार मंगळ {$lagnaHouse} व्या भावात होता, परंतु भाव चलितनुसार तो {$chalitHouse} व्या भावात येतो).";
                }
            } else {
                if ($hasMangalLagna) {
                    $desc = "{$labelGenitive} लग्न कुंडलीनुसार मंगळ {$lagnaHouse} व्या भावात असल्याने मंगळ दोष भासत होता; परंतु भाव चलित कुंडलीनुसार मंगळ {$chalitHouse} व्या भावात सरकल्यामुळे भाव चलितनुसार मंगळ दोष रद्द (दोषमुक्त) होतो.";
                } else {
                    $desc = "{$labelGenitive} भाव चलित कुंडलीनुसार मंगळ {$chalitHouse} व्या भावात असून १, ४, ७, ८, १२ या स्थानांत नसल्याने मंगळ दोष नाही.";
                }
            }

            return [
                'has_mangal' => $hasMangalChalit,
                'chalit_house' => $chalitHouse,
                'has_mangal_lagna' => $hasMangalLagna,
                'lagna_house' => $lagnaHouse,
                'shifted' => ($lagnaHouse !== $chalitHouse),
                'description' => $desc,
            ];
        };

        $boyMangalInfo = $buildPersonMangalDesc('युवक', $boyLagnaHouse, $boyChalitHouse, $boyHasMangalChalit, $boyHasMangalLagna);
        $girlMangalInfo = $buildPersonMangalDesc('युवती', $girlLagnaHouse, $girlChalitHouse, $girlHasMangalChalit, $girlHasMangalLagna);

        if (! $boyHasMangalChalit && ! $girlHasMangalChalit) {
            $mangalSummary = 'युवक आणि युवती या दोघांच्याही भाव चलित कुंडलीनुसार मंगळ १, ४, ७, ८, १२ या स्थानांत नसल्याने मंगळ दोष मानला जात नाही.';
            $mangalStatus = 'निर्दोष';
        } elseif ($boyHasMangalChalit && $girlHasMangalChalit) {
            $mangalSummary = 'दोन्ही कुंडलींमध्ये भाव चलित कुंडलीनुसार मंगळ दोष असल्याने मंगळ दोष रद्द (मंगळ साम्य) मानला जातो.';
            $mangalStatus = 'मंगळ साम्य (दोष परिहार)';
        } elseif ($boyHasMangalChalit) {
            $mangalSummary = "युवकाच्या भाव चलित कुंडलीत मंगळ दोष आहे ({$boyChalitHouse} व्या स्थानी मंगळ), परंतु युवतीच्या भाव चलित कुंडलीत मंगळ दोष नाही.";
            $mangalStatus = 'युवक मंगळ दोष';
        } else {
            $mangalSummary = "युवतीच्या भाव चलित कुंडलीत मंगळ दोष आहे ({$girlChalitHouse} व्या स्थानी मंगळ), परंतु युवकाच्या भाव चलित कुंडलीत मंगळ दोष नाही.";
            $mangalStatus = 'युवती मंगळ दोष';
        }

        $mangalDetails = [
            'boy' => $boyMangalInfo,
            'girl' => $girlMangalInfo,
            'status' => $mangalStatus,
            'summary' => $mangalSummary,
            'is_samya' => ($boyHasMangalChalit && $girlHasMangalChalit),
            'is_clear' => (! $boyHasMangalChalit && ! $girlHasMangalChalit),
        ];

        $gunMilanResult = $this->gunMilanCalculator->calculate(
            $boyData['panchang']['rashi']['index'],
            $boyData['panchang']['nakshatra']['index'],
            $girlData['panchang']['rashi']['index'],
            $girlData['panchang']['nakshatra']['index'],
            $boyHasMangalChalit,
            $girlHasMangalChalit,
            $mangalDetails
        );

        return [
            'success' => true,
            'engine' => $boyData['engine'],
            'boy' => $boyData,
            'girl' => $girlData,
            'gun_milan' => $gunMilanResult,
            'mangal_dosha' => $mangalDetails,
        ];
    }
}
