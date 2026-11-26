<?php

use App\Services\Astrology\AstrologyData;
use App\Services\Astrology\AvakhadaChakra;
use App\Services\Astrology\ChalitCalculator;
use App\Services\Astrology\ChartRenderer;
use App\Services\Astrology\GunMilanCalculator;
use App\Services\Astrology\MahadashaCalculator;
use App\Services\Astrology\NavamshaCalculator;
use App\Services\Astrology\PanchangCalculator;

test('AstrologyData helper methods work correctly', function () {
    // 0 deg = Mesha (Aries, index 0)
    expect(AstrologyData::getRashiIndex(0.0))->toBe(0)
        // 35 deg = Vrishabha (Taurus, index 1)
        ->and(AstrologyData::getRashiIndex(35.0))->toBe(1)
        // 359 deg = Meena (Pisces, index 11)
        ->and(AstrologyData::getRashiIndex(359.9))->toBe(11);

    // Degree details for 23.9861°
    $deg = AstrologyData::getDegreeDetails(23.9861);
    expect($deg['deg'])->toBe(23)
        ->and($deg['min'])->toBe(59)
        ->and($deg['display'])->toBe("23°59'");

    // Nakshatra index for 0 deg = Ashwini (index 0)
    expect(AstrologyData::getNakshatraIndex(0.0))->toBe(0)
        ->and(AstrologyData::getNakshatraPada(0.0))->toBe(1)
        ->and(AstrologyData::getNakshatraSyllable(0, 1))->toBe('चू');
});

test('PanchangCalculator computes tithi, nakshatra, yoga, karana, and moon rashi', function () {
    $calculator = new PanchangCalculator;
    // Sun at 140°, Moon at 250°
    $panchang = $calculator->calculate(140.0, 250.0);

    expect($panchang)->toHaveKeys(['tithi', 'nakshatra', 'yoga', 'karana', 'rashi'])
        ->and($panchang['tithi'])->toHaveKeys(['index', 'number', 'name', 'paksha', 'display'])
        ->and($panchang['nakshatra'])->toHaveKeys(['index', 'name', 'pada', 'lord', 'syllable'])
        ->and($panchang['yoga'])->toHaveKeys(['index', 'name'])
        ->and($panchang['karana'])->toHaveKeys(['index', 'name'])
        ->and($panchang['rashi'])->toHaveKeys(['index', 'name', 'lord']);
});

test('NavamshaCalculator correctly computes D9 divisions', function () {
    $navamsha = new NavamshaCalculator;

    // Mesha (movable sign 0):
    // 0° to 3°20' => Mesha (0)
    expect($navamsha->calculateNavamshaRashi(1.0))->toBe(0);
    // 3°20' to 6°40' => Vrishabha (1)
    expect($navamsha->calculateNavamshaRashi(4.0))->toBe(1);

    // Vrishabha (fixed sign 1): start is 9th from 1 => Makar (index 9)
    expect($navamsha->calculateNavamshaRashi(31.0))->toBe(9);
});

test('ChalitCalculator assigns planets to cusp houses', function () {
    $chalit = new ChalitCalculator;
    $houseCusps = [
        1 => 10.0,
        2 => 40.0,
        3 => 70.0,
        4 => 100.0,
        5 => 130.0,
        6 => 160.0,
        7 => 190.0,
        8 => 220.0,
        9 => 250.0,
        10 => 280.0,
        11 => 310.0,
        12 => 340.0,
    ];

    $planets = [
        'sun' => ['longitude' => 15.0],  // in house 1
        'moon' => ['longitude' => 105.0], // in house 4
    ];

    $assignments = $chalit->assignPlanetsToHouses($planets, $houseCusps);
    expect($assignments['sun'])->toBe(1)
        ->and($assignments['moon'])->toBe(4);

    $chart = $chalit->buildChalitChart($planets, $houseCusps);
    expect($chart[1])->toContain('sun')
        ->and($chart[4])->toContain('moon');
});

test('MahadashaCalculator calculates 9 Vimshottari periods starting from birth moon nakshatra', function () {
    $calculator = new MahadashaCalculator;
    $birthDate = new DateTime('2000-09-06 19:30:00');
    // Ashwini nakshatra (Moon at 5°) -> lord is Ketu
    $periods = $calculator->calculate(5.0, $birthDate);

    expect(count($periods))->toBe(9)
        ->and($periods[0]['planet_key'])->toBe('ketu')
        ->and($periods[1]['planet_key'])->toBe('venus')
        ->and($periods[2]['planet_key'])->toBe('sun');
});

test('AvakhadaChakra returns correct attributes', function () {
    $avakhada = new AvakhadaChakra;
    // Moon in Mesha (0), Ashwini (0)
    $res = $avakhada->calculate(0, 0);

    expect($res['varna'])->toBe('क्षत्रिय')
        ->and($res['tattva'])->toBe('अग्नि')
        ->and($res['yoni'])->toBe('अश्व')
        ->and($res['gana'])->toBe('देव')
        ->and($res['nadi'])->toBe('आद्य');
});

test('GunMilanCalculator calculates 36-point Ashtakoot matchmaking', function () {
    $calculator = new GunMilanCalculator;

    // Boy: Mesha (0), Ashwini (0)
    // Girl: Mesha (0), Ashwini (0)
    // Same Nadi => Nadi Dosha (0 pts)
    $res = $calculator->calculate(0, 0, 0, 0);

    expect($res['total_max'])->toBe(36)
        ->and($res['total_obtained'])->toBeGreaterThanOrEqual(0)
        ->and(count($res['gunas']))->toBe(9)
        ->and($res['conclusion'])->toBeString();
});

test('ChartRenderer generates valid SVG markup', function () {
    $renderer = new ChartRenderer;
    $chartData = [
        'houses' => [1 => ['sun'], 2 => ['moon'], 3 => [], 4 => [], 5 => [], 6 => [], 7 => [], 8 => [], 9 => [], 10 => [], 11 => [], 12 => []],
        'ascendant_rashi' => 0,
        'title' => 'लग्न कुंडली',
    ];

    $svg = $renderer->createChartSVG($chartData);
    expect($svg)->toContain('<svg')
        ->and($svg)->toContain('</svg>')
        ->and($svg)->toContain('लग्न')
        ->and($svg)->toContain('रवि')
        ->and($svg)->toContain('चंद्र');
});
