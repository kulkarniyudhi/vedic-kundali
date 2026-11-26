<?php

namespace App\Services\Astrology;

class ChartRenderer
{
    private array $planetLabels = [
        'sun' => 'रवि',
        'moon' => 'चंद्र',
        'mars' => 'मंगळ',
        'mercury' => 'बुध',
        'jupiter' => 'गुरु',
        'venus' => 'शुक्र',
        'saturn' => 'शनि',
        'rahu' => 'राहू',
        'ketu' => 'केतु',
        'uranus' => 'हर्षल',
        'neptune' => 'नेप.',
        'pluto' => 'प्लुटो',
    ];

    private array $housePositions = [
        1 => ['x' => 200, 'y' => 105],
        2 => ['x' => 105, 'y' => 60],
        3 => ['x' => 60,  'y' => 105],
        4 => ['x' => 105, 'y' => 200],
        5 => ['x' => 60,  'y' => 295],
        6 => ['x' => 105, 'y' => 340],
        7 => ['x' => 200, 'y' => 295],
        8 => ['x' => 295, 'y' => 340],
        9 => ['x' => 340, 'y' => 295],
        10 => ['x' => 295, 'y' => 200],
        11 => ['x' => 340, 'y' => 105],
        12 => ['x' => 295, 'y' => 60],
    ];

    private array $houseNumberPositions = [
        1 => ['x' => 200, 'y' => 35],
        2 => ['x' => 105, 'y' => 25],
        3 => ['x' => 25,  'y' => 105],
        4 => ['x' => 45,  'y' => 200],
        5 => ['x' => 25,  'y' => 295],
        6 => ['x' => 105, 'y' => 375],
        7 => ['x' => 200, 'y' => 365],
        8 => ['x' => 295, 'y' => 375],
        9 => ['x' => 375, 'y' => 295],
        10 => ['x' => 355, 'y' => 200],
        11 => ['x' => 375, 'y' => 105],
        12 => ['x' => 295, 'y' => 25],
    ];

    /**
     * @param  array{houses: array<int, array<int, string>>, ascendant_rashi: int, title?: string}  $chartData
     * @param  array<string, array<string, mixed>>  $planetData
     * @return string SVG markup
     */
    public function createChartSVG(array $chartData, array $planetData = [], bool $showDegrees = false): string
    {
        $houses = $chartData['houses'];
        $ascRashi = $chartData['ascendant_rashi'];
        $size = 400;
        $mid = $size / 2;

        $svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" width="100%" height="100%">';
        $svg .= '<rect x="0" y="0" width="400" height="400" fill="#ffffff" rx="4"/>';
        $svg .= '<rect x="10" y="10" width="380" height="380" fill="none" stroke="#d45d00" stroke-width="1.5"/>';
        $svg .= '<line x1="10" y1="10" x2="390" y2="390" stroke="rgba(212,93,0,0.5)" stroke-width="1"/>';
        $svg .= '<line x1="390" y1="10" x2="10" y2="390" stroke="rgba(212,93,0,0.5)" stroke-width="1"/>';
        $svg .= '<polygon points="200,10 390,200 200,390 10,200" fill="none" stroke="rgba(212,93,0,0.5)" stroke-width="1"/>';

        $svg .= '<rect x="185" y="190" width="30" height="20" fill="#ffffff" />';
        $svg .= sprintf(
            '<text x="%d" y="%d" text-anchor="middle" fill="rgba(200,75,49,0.5)" font-family="freeserif" font-size="14">लग्न</text>',
            $mid,
            $mid + 5
        );

        for ($h = 1; $h <= 12; $h++) {
            $numPos = $this->houseNumberPositions[$h];
            $rashiNumber = ($ascRashi + $h - 1) % 12 + 1;

            $svg .= sprintf(
                '<text x="%d" y="%d" text-anchor="middle" fill="rgba(0,0,0,0.45)" font-family="freesans, sans-serif" font-size="11">%d</text>',
                $numPos['x'],
                $numPos['y'] + 4,
                $rashiNumber
            );

            $planetsInHouse = $houses[$h] ?? [];
            if (! empty($planetsInHouse)) {
                $pos = $this->housePositions[$h];
                $planetItems = [];

                foreach ($planetsInHouse as $pid) {
                    $label = $this->planetLabels[$pid] ?? $pid;
                    $pInfo = $planetData[$pid] ?? [];
                    if (! empty($pInfo['retrograde']) && $pid !== 'rahu' && $pid !== 'ketu') {
                        $label .= '↓';
                    }
                    if ($showDegrees && ! empty($pInfo['degree'])) {
                        $label .= ' '.$pInfo['degree'];
                    }
                    $planetItems[] = ['text' => $label];
                }

                $fontSize = $showDegrees ? (count($planetItems) > 2 ? 10 : 11) : 13;
                $lineHeight = $showDegrees ? (count($planetItems) > 2 ? 13 : 15) : 16;
                $startY = $pos['y'] - ((count($planetItems) - 1) * $lineHeight) / 2;

                foreach ($planetItems as $idx => $item) {
                    $svg .= sprintf(
                        '<text x="%d" y="%d" text-anchor="middle" fill="#c84b31" font-family="freeserif" font-size="%d">%s</text>',
                        $pos['x'],
                        (int) ($startY + ($idx * $lineHeight)),
                        $fontSize,
                        htmlspecialchars($item['text'])
                    );
                }
            }
        }

        $svg .= '</svg>';

        return $svg;
    }
}
